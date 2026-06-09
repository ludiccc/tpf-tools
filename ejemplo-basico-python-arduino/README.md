# Ejemplo basico Python + Arduino

Este ejemplo manda numeros desde Python a Arduino por el puerto serial.

Python cuenta rapido de 1 a 5000 y despues vuelve de 5000 a 1. El numero que se esta mandando esta siempre en una variable llamada `valor`.

Arduino recibe ese numero, lo lleva al rango 0 a 1023 y despues mueve un servo entre 0 y 180 grados. Tambien imprime por el monitor serial el valor que recibio.

## Materiales

- Arduino
- Servo motor
- Cable USB
- Python instalado
- Libreria `pyserial`

## Conexion del servo

- Cable de senal del servo al pin 9
- Cable rojo del servo a 5V
- Cable marron o negro del servo a GND

Si el servo consume mucho, conviene alimentarlo con una fuente externa y unir el GND de la fuente con el GND de Arduino.

## Instalar la libreria de Python

```bash
pip install -r requirements.txt
```

## Elegir el puerto

En `enviar_valor.py` hay una variable al principio:

```python
PUERTO = "COM3"
```

Hay que cambiarla segun la compu:

```python
# Windows
PUERTO = "COM3"

# macOS
PUERTO = "/dev/tty.usbmodem1101"

# Linux
PUERTO = "/dev/ttyACM0"
```

No hay deteccion automatica. La idea es que el puerto quede escrito a mano y sea facil de ver.

## Como usarlo

1. Abrir `arduino_servo_serial/arduino_servo_serial.ino` en el IDE de Arduino.
2. Cargarlo en la placa.
3. Cerrar el monitor serial del IDE, porque si queda abierto ocupa el puerto.
4. Editar `PUERTO` en `enviar_valor.py`.
5. Ejecutar:

```bash
python enviar_valor.py
```

Para cortar el programa: `Ctrl+C`.
