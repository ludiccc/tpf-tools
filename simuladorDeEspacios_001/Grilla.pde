// ================= CLASE GRILLA =================

/**
 * Clase encargada de manejar la grilla de cuadrantes
 * Permite dividir el espacio en regiones para identificar en qué zona está cada usuario
 */
 
class Grilla {
  int divisiones;      // Cantidad total de cuadrantes (0, 1, 4, 9, etc.)
  int celdasX, celdasY; // Cantidad de celdas en cada eje
  float anchoCelda, altoCelda;  // Dimensiones de cada celda en píxeles
  
  Grilla(int div) {
    this.divisiones = div;
    if (divisiones > 0) {
      // Calculamos raíz cuadrada para grilla cuadrada (ej: 4 → 2x2, 9 → 3x3)
      int raiz = (int)sqrt(divisiones);
      celdasX = raiz;
      celdasY = raiz;
      anchoCelda = width / (float)celdasX;
      altoCelda = height / (float)celdasY;
    }
  }
  
  ///// Dibuja las líneas de la grilla en el canvas
  void dibujar() {
    if (divisiones == 0) return;  // Sin grilla, no dibujar nada
    
    stroke(80);
    strokeWeight(1);
    
    // Líneas verticales
    for (int i = 1; i < celdasX; i++) {
      line(i * anchoCelda, 0, i * anchoCelda, height);
    }
    
    // Líneas horizontales
    for (int i = 1; i < celdasY; i++) {
      line(0, i * altoCelda, width, i * altoCelda);
    }
  }
  
  //// Determina en qué cuadrante se encuentra un punto (x, y)
  int obtenerCuadrante(int x, int y) {
    if (divisiones == 0) return 0;
    
    int cx = (int)constrain(x / anchoCelda, 0, celdasX - 1);
    int cy = (int)constrain(y / altoCelda, 0, celdasY - 1);
    return (cy * celdasX + cx);
  }
}
