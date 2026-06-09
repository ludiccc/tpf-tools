import time
import serial


# Elegir el puerto segun la computadora.
# Windows: "COM3", "COM4", etc.
# macOS: "/dev/tty.usbmodem1101" o "/dev/tty.usbserial-110"
# Linux: "/dev/ttyACM0" o "/dev/ttyUSB0"
PUERTO = "COM3"

BAUDIOS = 9600
PAUSA = 0.001


arduino = serial.Serial(PUERTO, BAUDIOS)
time.sleep(2)

print("Enviando valores por serial. Ctrl+C para cortar.")

try:
    while True:
        for valor in range(1, 5001):
            arduino.write(f"{valor}\n".encode("utf-8"))
            print(valor)
            time.sleep(PAUSA)

        for valor in range(5000, 0, -1):
            arduino.write(f"{valor}\n".encode("utf-8"))
            print(valor)
            time.sleep(PAUSA)

except KeyboardInterrupt:
    print("\nCerrando puerto serial.")
    arduino.close()
