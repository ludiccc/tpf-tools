# tpf-tools

[🇬🇧 English version](README_en.md)

Herramientas y ejemplos para **Taller de Producción Final** (Taller 5 / TPF), licenciatura en Diseño Multimedial, Universidad Nacional de La Plata. Más información sobre la materia: [Taller 5](https://taller5.ludic.cc) · [www.ludic.cc](https://www.ludic.cc)

Este repositorio reúne ejemplos sencillos para conectar software, cámaras, sonido y hardware en instalaciones de arte electrónico/digital/robótico. Son de **uso académico**: sirven como punto de partida y no como referencia formal de las tecnologías que usan.

## Contenido

| Carpeta | Lenguaje / entorno | Qué hace |
| --- | --- | --- |
| [mediapipe_for_installations/](mediapipe_for_installations/) *(submódulo)* | Python + MediaPipe, OSC | Detección de pose, manos, gestos, cara y blobs con envío de datos por OSC. |
| [mapping/](mapping/) | Processing | Herramientas de video mapping con webcam: calibración de entrada, de salida o de ambas. |
| [multicamara/](multicamara/) | Python + OpenCV | Dos cámaras lado a lado, con corrección de perspectiva por cuatro esquinas y variante con rastro (delay). |
| [simuladorDeEspacios_001/](simuladorDeEspacios_001/) | Processing + OSC | Simula usuarios que se mueven por un espacio y envía posición y cuadrante por OSC. |
| [ejemplo-basico-python-arduino/](ejemplo-basico-python-arduino/) | Python + Arduino | Envía números por puerto serial para mover un servo. |
| [ejemplo-basico-microfono-openai/](ejemplo-basico-microfono-openai/) | Python + OpenAI | Micrófono → speech to text → OpenAI → respuesta en terminal. |

### [mediapipe_for_installations](mediapipe_for_installations/) (submódulo)

Repositorio de la misma cátedra: [ludiccc/mediapipe_for_installations](https://github.com/ludiccc/mediapipe_for_installations). Incluye la app todo-en-uno `mediapipe_osc.py` (pose, manos, gestos, cara y blobs, con IDs estables, panel de control, entrada de Kinect y formatos OSC compatibles con Processing), scripts de ejemplo, sketches receptores y demos de sonido cuadrafónico. Ver su [README](https://github.com/ludiccc/mediapipe_for_installations/blob/main/README.md).

### [mapping](mapping/)

Tres sketches de Processing que trabajan con cuatro vértices normalizados (guardados en `.json`): `mapping_in` (qué zona de la cámara se usa), `mapping_out` (dónde y con qué deformación se proyecta) y `mapping_in_mapping_out` (ambos en un mismo sketch). Requiere Processing, la librería de video y una webcam. Detalle en [mapping/README.md](mapping/README.md).

### [multicamara](multicamara/)

Abre dos cámaras (dispositivos `0` y `1` de OpenCV, `640x480`) y permite elegir cuatro esquinas por cámara para corregir la perspectiva. `multicamara-con-delay.py` agrega un rastro acumulativo. Las calibraciones se guardan en `multicamara.json`. Detalle en [multicamara/README.md](multicamara/README.md).

### [simuladorDeEspacios_001](simuladorDeEspacios_001/)

Sketch de Processing que simula usuarios autónomos (o controlados con el mouse) en un espacio dividido en cuadrantes, y envía por OSC `/usuario/[id]/posicion` y `/usuario/[id]/cuadrante` a `127.0.0.1:12000`. Permite probar instalaciones sin cámaras ni personas. Requiere la librería oscP5. Detalle en [simuladorDeEspacios_001/README.md](simuladorDeEspacios_001/README.md).

### [ejemplo-basico-python-arduino](ejemplo-basico-python-arduino/)

Python cuenta de 1 a 5000 y de vuelta, y manda cada valor por serial; el Arduino lo lleva al rango 0–1023 y mueve un servo (pin 9). Requiere `pyserial` y ajustar `PUERTO` en `enviar_valor.py`. Detalle en [ejemplo-basico-python-arduino/README.md](ejemplo-basico-python-arduino/README.md).

### [ejemplo-basico-microfono-openai](ejemplo-basico-microfono-openai/)

Graba 5 segundos de audio, lo transcribe (`whisper-1`) y envía el texto a OpenAI (`gpt-4o-mini`). Requiere una API key en la variable de entorno `OPENAI_API_KEY`. Detalle en [ejemplo-basico-microfono-openai/README.md](ejemplo-basico-microfono-openai/README.md).

## Cómo obtener el repositorio

El repositorio incluye un submódulo, por lo que hay que clonarlo con:

```bash
git clone --recurse-submodules https://github.com/ludiccc/tpf-tools.git
```

Si ya se clonó sin submódulos:

```bash
git submodule update --init --recursive
```

## Requisitos generales

- [Python 3](https://www.python.org/) para los ejemplos en Python. Cada carpeta tiene su propio `requirements.txt`; conviene usar un entorno virtual o de conda por ejemplo:

  ```bash
  pip install -r requirements.txt
  ```

- [Processing](https://processing.org/) para `mapping/` y `simuladorDeEspacios_001/` (librerías: `video` para mapping, `oscP5` para el simulador).
- [Arduino IDE](https://www.arduino.cc/en/software) y una placa Arduino para el ejemplo con servo.
- Cuenta y API key de [OpenAI](https://platform.openai.com/) para el ejemplo de micrófono.
- Webcam(s) para mapping, multicámara y MediaPipe.

## Cómo se conectan los ejemplos

Varios ejemplos están pensados para combinarse mediante **OSC** (puerto `12000` por defecto en este material): `mediapipe_osc.py` o `simuladorDeEspacios_001` actúan como emisores, y Processing, Arduino (vía Python), TouchDesigner u otro software como receptores.

## Contacto

[www.ludic.cc](https://www.ludic.cc) · [Taller 5](https://taller5.ludic.cc)
