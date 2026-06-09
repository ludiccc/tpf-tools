#include <Servo.h>

Servo servo;

const int PIN_SERVO = 9;

void setup() {
  Serial.begin(9600);
  servo.attach(PIN_SERVO);
  servo.write(0);
}

void loop() {
  if (Serial.available() > 0) {
    int valor = Serial.parseInt();

    if (valor > 0) {
      int movimiento_servo = map(valor, 1, 5000, 0, 1023);
      movimiento_servo = constrain(movimiento_servo, 0, 1023);

      int angulo = map(movimiento_servo, 0, 1023, 0, 180);
      servo.write(angulo);

      Serial.print("Valor recibido: ");
      Serial.print(valor);
      Serial.print(" | Valor 0-1023: ");
      Serial.print(movimiento_servo);
      Serial.print(" | Angulo servo: ");
      Serial.println(angulo);
    }
  }
}
