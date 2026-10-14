# tpf-tools

[🇦🇷 Versión en castellano](README.md)

Tools and examples for the **Final Production Workshop** (Taller 5 / TPF), degree in Multimedia Design, Universidad Nacional de La Plata. More about the subject: [Taller 5](https://taller5.ludic.cc) · [www.ludic.cc](https://www.ludic.cc)

This repository gathers simple examples to connect software, cameras, sound and hardware in electronic/digital/robotic art installations. They are for **academic use**: they are starting points, not a formal reference for the technologies they use.

## Contents

| Folder | Language / environment | What it does |
| --- | --- | --- |
| [mediapipe_for_installations/](mediapipe_for_installations/) *(submodule)* | Python + MediaPipe, OSC | Pose, hands, gestures, face and blob detection, sending data over OSC. |
| [mapping/](mapping/) | Processing | Webcam video mapping tools: input calibration, output calibration, or both. |
| [multicamara/](multicamara/) | Python + OpenCV | Two cameras side by side, with four-corner perspective correction and a trail (delay) variant. |
| [simuladorDeEspacios_001/](simuladorDeEspacios_001/) | Processing + OSC | Simulates users moving through a space and sends position and quadrant over OSC. |
| [ejemplo-basico-python-arduino/](ejemplo-basico-python-arduino/) | Python + Arduino | Sends numbers over the serial port to move a servo. |
| [ejemplo-basico-microfono-openai/](ejemplo-basico-microfono-openai/) | Python + OpenAI | Microphone → speech to text → OpenAI → answer in the terminal. |

### [mediapipe_for_installations](mediapipe_for_installations/) (submodule)

Repository from the same course: [ludiccc/mediapipe_for_installations](https://github.com/ludiccc/mediapipe_for_installations). It includes the all-in-one app `mediapipe_osc.py` (pose, hands, gestures, face and blobs, with stable IDs, control panel, Kinect input and OSC formats compatible with Processing), example scripts, receiver sketches and quadraphonic sound demos. See its [README](https://github.com/ludiccc/mediapipe_for_installations/blob/main/README_en.md).

### [mapping](mapping/)

Three Processing sketches working with four normalized vertices (saved as `.json`): `mapping_in` (which camera area is used), `mapping_out` (where and with what distortion it is projected) and `mapping_in_mapping_out` (both in one sketch). Requires Processing, the video library and a webcam. Details in [mapping/README.md](mapping/README.md) (Spanish).

### [multicamara](multicamara/)

Opens two cameras (OpenCV devices `0` and `1`, `640x480`) and lets you pick four corners per camera to correct perspective. `multicamara-con-delay.py` adds a cumulative trail. Calibrations are saved in `multicamara.json`. Details in [multicamara/README.md](multicamara/README.md) (Spanish).

### [simuladorDeEspacios_001](simuladorDeEspacios_001/)

Processing sketch that simulates autonomous (or mouse-controlled) users in a space divided into quadrants, and sends `/usuario/[id]/posicion` and `/usuario/[id]/cuadrante` over OSC to `127.0.0.1:12000`. Lets you test installations without cameras or people. Requires the oscP5 library. Details in [simuladorDeEspacios_001/README.md](simuladorDeEspacios_001/README.md) (Spanish).

### [ejemplo-basico-python-arduino](ejemplo-basico-python-arduino/)

Python counts from 1 to 5000 and back, sending each value over serial; the Arduino maps it to the 0–1023 range and moves a servo (pin 9). Requires `pyserial` and setting `PUERTO` in `enviar_valor.py`. Details in [ejemplo-basico-python-arduino/README.md](ejemplo-basico-python-arduino/README.md) (Spanish).

### [ejemplo-basico-microfono-openai](ejemplo-basico-microfono-openai/)

Records 5 seconds of audio, transcribes it (`whisper-1`) and sends the text to OpenAI (`gpt-4o-mini`). Requires an API key in the `OPENAI_API_KEY` environment variable. Details in [ejemplo-basico-microfono-openai/README.md](ejemplo-basico-microfono-openai/README.md) (Spanish).

## Getting the repository

The repository includes a submodule, so clone it with:

```bash
git clone --recurse-submodules https://github.com/ludiccc/tpf-tools.git
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

## General requirements

- [Python 3](https://www.python.org/) for the Python examples. Each folder has its own `requirements.txt`; using a virtual or conda environment is recommended:

  ```bash
  pip install -r requirements.txt
  ```

- [Processing](https://processing.org/) for `mapping/` and `simuladorDeEspacios_001/` (libraries: `video` for mapping, `oscP5` for the simulator).
- [Arduino IDE](https://www.arduino.cc/en/software) and an Arduino board for the servo example.
- An [OpenAI](https://platform.openai.com/) account and API key for the microphone example.
- Webcam(s) for mapping, multicamera and MediaPipe.

## How the examples connect

Several examples are designed to be combined through **OSC** (port `12000` by default in this material): `mediapipe_osc.py` or `simuladorDeEspacios_001` act as senders, and Processing, Arduino (via Python), TouchDesigner or other software as receivers.

## Contact

[www.ludic.cc](https://www.ludic.cc) · [Taller 5](https://taller5.ludic.cc)
