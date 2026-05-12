/**
 Simulación de cámaras detectando usuarios (puntos móviles)
  - Envía datos por OSC a otras aplicaciones

Controles: 
  - Click sobre un punto: lo engancha al mouse (movimiento 1 a 1), click otra vez lo suelta.
  - Teclas " + / - " : cambiar cantidad de usuarios (1 a 10)
  - Tecla "i" : muestra/esconde los mensajes que se están mandando
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress destino;

ArrayList<User> usuarios;
Grilla grilla;

int cantidadUsuarios = 1;
int divisionesGrilla = 9;  // 0 = sin grilla
boolean mostrarPanelOSC = true;  // Estado del panel OSC (visible por defecto)

int puertoOSC = 12000;

PFont font;

void setup() {
  size(800, 600);
  frameRate(60);

  // Inicializar OSC (envía a localhost, puerto 12000)
  oscP5 = new OscP5(this, 9000);   // Puerto para recibir
  destino = new NetAddress("127.0.0.1", puertoOSC);   // Dirección de destino

  grilla = new Grilla(divisionesGrilla);
  usuarios = new ArrayList<User>();

  actualizarUsuarios();
}

void draw() {
  background(30);

  // Dibujar la grilla (si está activada)
  grilla.dibujar();

  // Actualizar y dibujar todos los usuarios
  for (User u : usuarios) {
    u.actualizar();
    u.dibujar();
  }

  // Enviar datos por OSC a la aplicación externa
  enviarDatosOSC();

  // Mostrar información en pantalla (controles y estado)
  mostrarInfo();

  // Mostrar panel OSC solo si está activado
  if (mostrarPanelOSC) {
    mostrarInfoOSC();
  }
}

/// Crea o actualiza la lista de usuarios según la cantidad actual
void actualizarUsuarios() {
  usuarios.clear();
  for (int i = 0; i < cantidadUsuarios; i++) {
    usuarios.add(new User(i, grilla));
  }
}

/// Envía por OSC los datos de cada usuario: id, posición x, posición y, cuadrante
void enviarDatosOSC() {
  for (User u : usuarios) {
    // Mensaje de posición (x, y juntos)
    OscMessage posMsg = new OscMessage("/usuario/" + u.id + "/posicion");
    posMsg.add(u.pos.x);
    posMsg.add(u.pos.y);
    oscP5.send(posMsg, destino);

    guardarEnHistorial(posMsg);

    // Mensaje de cuadrante
    OscMessage cuadMsg = new OscMessage("/usuario/" + u.id + "/cuadrante");
    cuadMsg.add(u.cuadranteActual);
    oscP5.send(cuadMsg, destino);
    
    guardarEnHistorial(cuadMsg);


    // Debug
    println("OSC: /usuario/" + u.id + "/posicion " + u.pos.x + ", " + u.pos.y);
    println("OSC: /usuario/" + u.id + "/cuadrante " + u.cuadranteActual);
  }
}

//// Muestra en pantalla la información de controles y estado actual
void mostrarInfo() {
  textAlign(LEFT, TOP);
  fill(200);
  text("Usuarios: " + cantidadUsuarios + " (+/-)", 10, 20);
  text("Click sobre punto → sigue mouse (1 a 1) / autonomía", 10, 40);
  text("Mostar/Ocultar información → i", 10, 60);
}

//// Detecta clicks del mouse sobre algún usuario
void mousePressed() {
  for (User u : usuarios) {
    if (u.esClickeado(mouseX, mouseY)) {
      u.alternarModoSeguimiento();
      break;   // Solo un usuario por click
    }
  }
}

////  Maneja las teclas para modificar parámetros en tiempo real
void keyPressed() {
  if (key == '+') {
    // Aumentar cantidad de usuarios (máximo 10)
    cantidadUsuarios = min(cantidadUsuarios + 1, 10);
    actualizarUsuarios();
  } else if (key == '-') {
    // Disminuir cantidad de usuarios (mínimo 1)
    cantidadUsuarios = max(cantidadUsuarios - 1, 1);
    actualizarUsuarios();
  } else if (key == 'i' || key == 'I') {
    // Mostrar/ocultar panel OSC
    mostrarPanelOSC = !mostrarPanelOSC;
  }
}
