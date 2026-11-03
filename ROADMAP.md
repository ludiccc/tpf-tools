# Roadmap

Borrador de líneas de trabajo para `tpf-tools`. Se actualiza a medida que avanza la cursada y se abren issues.

## Hecho

- [x] Ejemplos base: mapping (Processing), multicámara (Python + OpenCV), simulador de espacios (Processing + OSC), Python → Arduino, micrófono → OpenAI.
- [x] Submódulo `mediapipe_for_installations` con detección de pose, manos, gestos, cara y blobs enviada por OSC.
- [x] READMEs en castellano e inglés.
- [x] Licencia MPL 2.0.

## Próximo

- [ ] Agregar encabezados de licencia en los archivos fuente (`.py`, `.pde`, `.ino`).
- [ ] Unificar la documentación en inglés de las subcarpetas (hoy están solo en castellano).
- [ ] Revisar y fijar versiones en cada `requirements.txt`.
- [ ] Documentar un flujo completo de ejemplo: MediaPipe → OSC → Processing/Arduino.
- [ ] Revisar licencias y consentimiento de imágenes incluidas en el submódulo.

## Ideas

- [ ] Ejemplos de recepción OSC en TouchDesigner y openFrameworks.
- [ ] Soporte para más de dos cámaras en `multicamara/`.
- [ ] Guía de calibración de video mapping con proyector real.
- [ ] Alternativas locales al ejemplo de OpenAI (speech to text y LLM sin API externa).
