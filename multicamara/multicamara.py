"""Vista y recorte perspectivo de dos camaras USB con OpenCV.

Controles:
    1 / 2       seleccionar la camara a editar
    mouse       arrastrar una esquina del cuadrilatero seleccionado
    Enter       aplicar el recorte perspectivo y volver a la vista normal
    e           editar nuevamente la camara seleccionada
    p           alternar pixelado
    r           restablecer las esquinas de la camara seleccionada
    q / Esc     salir
"""

from __future__ import annotations

import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional
import json

import cv2
import numpy as np


CAMERA_INDICES = (0, 2)
FRAME_WIDTH = 640
FRAME_HEIGHT = 480
WINDOW_NAME = "Multicamara"
HANDLE_RADIUS = 14
CONFIG_FILE = Path(__file__).with_name("multicamara.json")


@dataclass
class CameraState:
    capture: cv2.VideoCapture
    corners: np.ndarray = field(
        default_factory=lambda: np.array(
            [[0, 0], [FRAME_WIDTH - 1, 0], [FRAME_WIDTH - 1, FRAME_HEIGHT - 1], [0, FRAME_HEIGHT - 1]],
            dtype=np.float32,
        )
    )
    mapped: bool = False
    frame: Optional[np.ndarray] = None


def open_camera(index: int) -> Optional[cv2.VideoCapture]:
    capture = cv2.VideoCapture(index)
    capture.set(cv2.CAP_PROP_FRAME_WIDTH, FRAME_WIDTH)
    capture.set(cv2.CAP_PROP_FRAME_HEIGHT, FRAME_HEIGHT)

    if not capture.isOpened():
        capture.release()
        return None

    actual_width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    actual_height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    if (actual_width, actual_height) != (FRAME_WIDTH, FRAME_HEIGHT):
        print(
            f"La camara {index} no acepto {FRAME_WIDTH}x{FRAME_HEIGHT}; "
            f"entrego {actual_width}x{actual_height}.",
            file=sys.stderr,
        )
        capture.release()
        return None

    return capture


def reset_corners(state: CameraState) -> None:
    state.corners = np.array(
        [[0, 0], [FRAME_WIDTH - 1, 0], [FRAME_WIDTH - 1, FRAME_HEIGHT - 1], [0, FRAME_HEIGHT - 1]],
        dtype=np.float32,
    )
    state.mapped = False


def load_settings(states: list[CameraState]) -> None:
    if not CONFIG_FILE.exists():
        return

    try:
        settings = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
        saved_cameras = settings.get("cameras", [])
        for state, saved_camera in zip(states, saved_cameras):
            corners = np.asarray(saved_camera["corners"], dtype=np.float32)
            if corners.shape != (4, 2):
                raise ValueError("las esquinas deben tener cuatro puntos")
            state.corners = np.clip(corners, (0, 0), (FRAME_WIDTH - 1, FRAME_HEIGHT - 1))
            state.mapped = bool(saved_camera.get("mapped", True))
    except (OSError, json.JSONDecodeError, KeyError, TypeError, ValueError) as error:
        print(f"No se pudo cargar {CONFIG_FILE.name}: {error}. Se usaran valores por defecto.", file=sys.stderr)


def save_settings(states: list[CameraState]) -> None:
    settings = {
        "width": FRAME_WIDTH,
        "height": FRAME_HEIGHT,
        "cameras": [
            {
                "corners": state.corners.astype(float).tolist(),
                "mapped": state.mapped,
            }
            for state in states
        ],
    }
    CONFIG_FILE.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")


def apply_perspective(frame: np.ndarray, corners: np.ndarray) -> np.ndarray:
    destination = np.array(
        [[0, 0], [FRAME_WIDTH - 1, 0], [FRAME_WIDTH - 1, FRAME_HEIGHT - 1], [0, FRAME_HEIGHT - 1]],
        dtype=np.float32,
    )
    transform = cv2.getPerspectiveTransform(corners.astype(np.float32), destination)
    return cv2.warpPerspective(frame, transform, (FRAME_WIDTH, FRAME_HEIGHT))


def pixelate(frame: np.ndarray, enabled: bool) -> np.ndarray:
    if not enabled:
        return frame

    small = cv2.resize(frame, (80, 60), interpolation=cv2.INTER_AREA)
    return cv2.resize(small, (FRAME_WIDTH, FRAME_HEIGHT), interpolation=cv2.INTER_NEAREST)


def draw_editor(frame: np.ndarray, corners: np.ndarray, camera_number: int) -> np.ndarray:
    result = frame.copy()
    polygon = corners.astype(np.int32).reshape((-1, 1, 2))
    cv2.polylines(result, [polygon], True, (0, 200, 255), 2)

    for number, (x, y) in enumerate(corners, start=1):
        point = (int(x), int(y))
        cv2.circle(result, point, HANDLE_RADIUS, (0, 200, 255), -1)
        cv2.circle(result, point, HANDLE_RADIUS, (255, 255, 255), 2)
        cv2.putText(result, str(number), (point[0] - 5, point[1] + 6), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 2)

    cv2.putText(
        result,
        f"Editando camara {camera_number} | Enter: aplicar",
        (12, 28),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.65,
        (255, 255, 255),
        2,
    )
    return result


def draw_label(frame: np.ndarray, text: str) -> np.ndarray:
    result = frame.copy()
    cv2.rectangle(result, (0, 0), (result.shape[1], 38), (0, 0, 0), -1)
    cv2.putText(result, text, (12, 26), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255, 255, 255), 2)
    return result


def main() -> int:
    states = []
    for index in CAMERA_INDICES:
        capture = open_camera(index)
        if capture is None:
            for state in states:
                state.capture.release()
            print(f"No se pudo abrir la camara {index}.", file=sys.stderr)
            return 1
        states.append(CameraState(capture=capture))
    load_settings(states)

    selected_camera = 0
    editing = False
    pixelated = False
    dragging_corner: Optional[int] = None

    def mouse_callback(event: int, x: int, y: int, _flags: int, _param: object) -> None:
        nonlocal dragging_corner
        if not editing:
            return

        selected_state = states[selected_camera]
        local_x = x if selected_camera == 0 else x - FRAME_WIDTH
        if not 0 <= local_x < FRAME_WIDTH or not 0 <= y < FRAME_HEIGHT:
            return

        if event == cv2.EVENT_LBUTTONDOWN:
            distances = np.linalg.norm(selected_state.corners - (local_x, y), axis=1)
            nearest = int(np.argmin(distances))
            if distances[nearest] <= HANDLE_RADIUS * 2:
                dragging_corner = nearest
        elif event == cv2.EVENT_MOUSEMOVE and dragging_corner is not None:
            selected_state.corners[dragging_corner] = (
                np.clip(local_x, 0, FRAME_WIDTH - 1),
                np.clip(y, 0, FRAME_HEIGHT - 1),
            )
        elif event == cv2.EVENT_LBUTTONUP:
            dragging_corner = None

    cv2.namedWindow(WINDOW_NAME)
    cv2.setMouseCallback(WINDOW_NAME, mouse_callback)

    try:
        while True:
            for state in states:
                ok, frame = state.capture.read()
                if not ok:
                    print("No se pudo leer una de las camaras.", file=sys.stderr)
                    return 1
                state.frame = frame

            output_frames = []
            for number, state in enumerate(states):
                assert state.frame is not None
                current = apply_perspective(state.frame, state.corners) if state.mapped else state.frame.copy()
                current = pixelate(current, pixelated)
                if editing and number == selected_camera:
                    current = draw_editor(current, state.corners, number + 1)
                else:
                    current = draw_label(current, f"Camara {number + 1}")
                output_frames.append(current)

            combined = np.hstack(output_frames)
            cv2.putText(
                combined,
                f"Seleccion: {selected_camera + 1} | 1/2 camara | e editar | p pixelado: {'ON' if pixelated else 'OFF'} | q salir",
                (12, FRAME_HEIGHT - 12),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (255, 255, 255),
                1,
            )
            cv2.imshow(WINDOW_NAME, combined)

            key = cv2.waitKey(1) & 0xFF
            if key in (ord("q"), 27):
                break
            if key in (ord("1"), ord("2")):
                selected_camera = key - ord("1")
                editing = True
                dragging_corner = None
            elif key == ord("e"):
                editing = True
                dragging_corner = None
            elif key in (10, 13) and editing:
                states[selected_camera].mapped = True
                save_settings(states)
                editing = False
                dragging_corner = None
            elif key == ord("p"):
                pixelated = not pixelated
            elif key == ord("r"):
                reset_corners(states[selected_camera])
                editing = False
    finally:
        for state in states:
            state.capture.release()
        cv2.destroyAllWindows()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
