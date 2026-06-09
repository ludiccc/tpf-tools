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

proximo_envio = 0

print("Enviando valores por serial. Ctrl+C para cortar.")

try:
    valor = 0
    direccion = 1
    while True:
        valor += direccion
        if valor >= 5000:
            direccion = -1
        elif valor <= 0:
            direccion = 1
        
        print(valor)

        if time.time() >= proximo_envio:
            arduino.write(f"{valor}\n".encode("utf-8"))
            proximo_envio = time.time() + PAUSA

except KeyboardInterrupt:
    print("\nCerrando puerto serial.")
    arduino.close()
