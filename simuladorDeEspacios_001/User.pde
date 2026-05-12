// ================= CLASE USUARIO =================

/**
Clase que representa un usuario/punto en la simulación
  - Maneja movimiento autónomo, seguimiento del mouse, pausas, etc.
  - Tiende a moverse cerca del centro y evita bordes
 */
 
class User {
  int id;                    // Identificador único del usuario
  PVector pos;               // Posición actual (x, y)
  PVector velocidad;         // Vector de velocidad actual (con dirección)
  float velBase;             // Velocidad base
  float velActual;           // Velocidad actual (sin dirección)
  color col;                 // Color del círculo
  boolean siguiendoMouse;    // True si está siguiendo al mouse
  
  // Para pausas aleatorias
  int tiempoPausa;
  boolean enPausa;
  
  // Para comportamiento de evitar bordes y tender al centro
  float margenSeguridad;     // Distancia desde el borde donde empieza a reaccionar
  float fuerzaCentro;        // Qué tan fuerte tiende al centro
  float fuerzaBorde;         // Qué tan fuerte rebota suavemente en bordes
  
  Grilla g;                  // Referencia a la grilla para calcular cuadrante
  int cuadranteActual;       // Cuadrante actual del usuario
  
  User(int id, Grilla g) {
    this.id = id;
    this.velBase = 1.5;
    this.g = g;
    
    // Configuración de comportamiento "humano"
    margenSeguridad = 100;    // A partir de 100px del borde empieza a evitar
    fuerzaCentro = 0.03;      // Fuerza suave que atrae al centro
    fuerzaBorde = 0.06;       // Fuerza de repulsión de bordes
    
    // Posición inicial aleatoria, pero evitando los bordes extremos
    pos = new PVector(random(margenSeguridad, width - margenSeguridad), 
                      random(margenSeguridad, height - margenSeguridad));
    
    // Velocidad inicial con dirección aleatoria y magnitud cercana a la base
    velocidad = PVector.random2D();
    velocidad.mult(velBase);
    
    velActual = velBase;
    col = color(100, 150, 250);  // Azul claro
    siguiendoMouse = false;
    enPausa = false;
    tiempoPausa = 0;
    actualizarCuadrante();
  }
  
  //// Actualiza el estado del usuario cada frame
  void actualizar() {
    if (siguiendoMouse) {
      // Modo SEGUIMIENTO: la posición se iguala directamente a la del mouse (movimiento 1 a 1)
      pos.x = mouseX;
      pos.y = mouseY;
    } else {
      // Modo AUTÓNOMO: movimiento con pausas y cambios suaves de velocidad
      if (enPausa) {
        // Está en pausa: solo contar tiempo hasta que termine
        tiempoPausa--;
        if (tiempoPausa <= 0) {
          enPausa = false;
          // Al salir de pausa, reiniciar velocidad con dirección aleatoria
          velocidad = PVector.random2D();
          velocidad.mult(velActual);
        }
      } else {
        // Movimiento normal: actualizar velocidad y posición
        
        // Cambio suave de velocidad
        velActual += random(-0.05, 0.05);
        velActual = constrain(velActual, velBase * 0.7, velBase * 1.3);
        
        // Cambio de dirección 
        if (random(1) < 0.01) {
          PVector nuevo = PVector.random2D();
          velocidad.lerp(nuevo, 0.05);
          velocidad.normalize();
        }
        
        // OPCIONAL: se puede sacar para que anden random
        // COMPORTAMIENTO "HUMANO": tender al centro y evitar bordes
        aplicarComportamientoHumano();
        
        // Aplicar velocidad actual y mover
        velocidad.setMag(velActual);
        pos.add(velocidad);
        
        // Probabilidad de pausar
        if (random(1) < 0.001) {
          enPausa = true;
          tiempoPausa = int(random(30, 90));  // Pausas cortas: 0.5 a 1.5 segundos
        }
      }
    }
    
    // Restringir la posición para que nunca salga del canvas
    pos.x = constrain(pos.x, 0, width);
    pos.y = constrain(pos.y, 0, height);
    
    // Actualizar el cuadrante según la nueva posición
    actualizarCuadrante();
  }
  
  //// Aplica fuerzas que simulan comportamiento humano
  /////// - Tiende a moverse hacia el centro
  /////// - Evita los bordes suavemente
  void aplicarComportamientoHumano() {
    PVector centro = new PVector(width/2, height/2);
    PVector haciaCentro = PVector.sub(centro, pos);
    float distanciaAlCentro = haciaCentro.mag();
    
    // FUERZA HACIA EL CENTRO (más fuerte si está lejos del centro)
    if (distanciaAlCentro > 150) {
      // Normalizar y aplicar fuerza proporcional a la distancia
      haciaCentro.normalize();
      float intensidad = constrain(distanciaAlCentro / 500, 0, 0.5);
      haciaCentro.mult(fuerzaCentro * intensidad);
      velocidad.add(haciaCentro);
    }
    
    // EVITAR BORDES: empuja suavemente hacia adentro cuando está cerca
    PVector evitarBorde = new PVector(0, 0);
    
    // Borde izquierdo
    if (pos.x < margenSeguridad) {
      float factor = (margenSeguridad - pos.x) / margenSeguridad;
      evitarBorde.x += fuerzaBorde * factor;
    }
    // Borde derecho
    else if (pos.x > width - margenSeguridad) {
      float factor = (pos.x - (width - margenSeguridad)) / margenSeguridad;
      evitarBorde.x -= fuerzaBorde * factor;
    }
    
    // Borde superior
    if (pos.y < margenSeguridad) {
      float factor = (margenSeguridad - pos.y) / margenSeguridad;
      evitarBorde.y += fuerzaBorde * factor;
    }
    // Borde inferior
    else if (pos.y > height - margenSeguridad) {
      float factor = (pos.y - (height - margenSeguridad)) / margenSeguridad;
      evitarBorde.y -= fuerzaBorde * factor;
    }
    
    velocidad.add(evitarBorde);
    
    // Limitar velocidad máxima para que no se dispare
    velocidad.limit(velActual * 1.8);
  }
  
  //// Dibuja el usuario en el canvas
  void dibujar() {
    noStroke();
    fill(col);
    ellipse(pos.x, pos.y, 20, 20);
    
    // Mostrar el ID dentro del círculo
    fill(255);
    textAlign(CENTER, CENTER);
    text(str(id), pos.x, pos.y);
  }
  
  //// Verifica si el usuario fue clickeado
  boolean esClickeado(float mx, float my) {
    return dist(mx, my, pos.x, pos.y) < 10;
  }
  
  //// Alterna entre modo autónomo y modo seguir al mouse
  void alternarModoSeguimiento() {
    siguiendoMouse = !siguiendoMouse;
    if (siguiendoMouse) {
      col = color(255, 100, 100);  // Rojo cuando sigue al mouse
      enPausa = false;
    } else {
      col = color(100, 150, 250);  // Azul cuando vuelve a autónomo
      velocidad = PVector.random2D();
      velocidad.setMag(velActual);
    }
  }
  
  //// Actualiza la referencia a la grilla (cuando cambia la división)
  void actualizarGrilla(Grilla nuevaGrilla) {
    this.g = nuevaGrilla;
    actualizarCuadrante();
  }
  
  //// Calcula y actualiza el cuadrante actual según la posición y la grilla
  void actualizarCuadrante() {
    cuadranteActual = g.obtenerCuadrante((int)pos.x, (int)pos.y);
  }
}
