// Para el historial de mensajes OSC
HashMap<String, OscMessage> historialMensajes = new HashMap<String, OscMessage>();
ArrayList<String> ordenMensajes = new ArrayList<String>();
int maxMensajes = 10;  // Cantidad máxima de mensajes a mostrar

/**
 Guarda un mensaje OSC en el historial
 - Si la dirección ya existe, actualiza el mensaje
 - Si es nueva, la agrega al final
 */
void guardarEnHistorial(OscMessage msg) {
  String direccion = msg.addrPattern();

  // Si es una dirección nueva
  if (!historialMensajes.containsKey(direccion)) {
    ordenMensajes.add(direccion);

    // Limitar cantidad de mensajes en el historial
    if (ordenMensajes.size() > maxMensajes) {
      String viejo = ordenMensajes.remove(0);
      historialMensajes.remove(viejo);
    }
  }

  // Guardar o actualizar el mensaje
  historialMensajes.put(direccion, msg);
}

/**
 Muestra en el lado derecho de la pantalla el mensaje OSC que se está enviando
*/
void mostrarInfoOSC() {
  if (historialMensajes.isEmpty()) return;

  // Fondo semi-transparente
  fill(0, 0, 0, 200);
  noStroke();
  rect(width - 300, 0, 300, height);

  // Título y puerto
  fill(255, 200, 100);
  textAlign(LEFT, TOP);
  textSize(16);
  text("ENVIANDO OSC A:", width - 280, 10);
  textSize(16);
  fill(100, 255, 100);
  text("127.0.0.1:" + puertoOSC, width - 280, 30);

  // Separador
  stroke(80);
  strokeWeight(1);
  line(width - 300, 50, width, 50);
  noStroke();

  int yOffset = 60;

  // Mostrar cada mensaje en orden
  for (String direccion : ordenMensajes) {
    OscMessage msg = historialMensajes.get(direccion);
    if (msg == null) continue;

    // Verificar si hay espacio suficiente
    if (yOffset > height - 50) break;

    // Dirección del mensaje
    fill(200, 200, 100);
    textSize(14);
    text(direccion, width - 280, yOffset);
    yOffset += 16;

    // Mostrar argumentos
    Object[] args = msg.arguments();
    for (int i = 0; i < args.length; i++) {
      if (yOffset > height - 30) break;

      String valor = "";
      if (args[i] instanceof Integer) {
        valor = str((Integer)args[i]);
      } else if (args[i] instanceof Float) {
        valor = nf((Float)args[i], 1, 2);
      }

      fill(200, 200, 255);
      textSize(14);
      if (i == 0 && direccion.contains("posicion")) {
        text("  x: " + valor, width - 280, yOffset);
      } else if (i == 1 && direccion.contains("posicion")) {
        text("  y: " + valor, width - 280, yOffset);
      } else {
        text("  [" + i + "]: " + valor, width - 280, yOffset);
      }
      yOffset += 14;
    }

    yOffset += 6;  // Espacio entre mensajes
  }

  // Información adicional
  fill(150);
  textSize(14);
  text("Mostrando " + ordenMensajes.size() + " mensajes (max: " + maxMensajes + ")", width - 280, height - 20);
}
