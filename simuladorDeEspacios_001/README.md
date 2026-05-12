# Simulador de Cámaras Detección de Usuarios



Simulación interactiva de múltiples usuarios (puntos) que se mueven de forma autónoma por un espacio, con envío de datos en tiempo real vía OSC. Desarrollado en **Processing**.



## 🎯 Funcionalidades



- **Simulación de usuarios**: Puntos que se mueven con comportamiento similar a personas (velocidad variable, pausas aleatorias, tendencia a evitar bordes y moverse hacia el centro)

- **Seguimiento con mouse**: Click sobre un punto → el usuario sigue al mouse (movimiento 1:1) → click nuevamente para volver a movimiento autónomo

- **Grilla configurable**: División del espacio en cuadrantes (cualquier número, no solo cuadrados perfectos)

- **Envío OSC**: Cada usuario envía su posición y cuadrante vía OSC a `127.0.0.1:12000`

- **Monitor OSC en pantalla**: Panel visual que muestra los mensajes OSC enviados en tiempo real



## 🎮 Controles

| Acción | Tecla / Input |
|--------|---------------|
| Aumentar cantidad de usuarios | `+` |
| Disminuir cantidad de usuarios | `-` |
| Mostrar/Ocultar panel OSC | `i` |
| Clickear usuario | Sigue al mouse (1:1) |
| Clickear usuario nuevamente | Vuelve a movimiento autónomo |

## 📡 Formato de mensajes OSC
### Posición

/usuario/\[id]/posicion \[x] \[y]

- `\[id]`: Identificador del usuario (0, 1, 2...)

- `\[x]`: Coordenada X en píxeles

- `\[y]`: Coordenada Y en píxeles

### Cuadrante

/usuario/\[id]/cuadrante \[cuadrante]

- `\[id]`: Identificador del usuario
- `\[cuadrante]`: Número de cuadrante (0 a divisiones-1)

### Ejemplo

- `/usuario/0/posicion 456.23 234.87`
- `/usuario/0/cuadrante 3`
- `/usuario/1/posicion 123.45 567.89`
- `/usuario/1/cuadrante 1`

## 🏗️ Estructura del código

- `simuladorDeEspacios001.pde` - Archivo principal (setup, draw, controles)
- `Grilla.pde` - Clase Grilla (gestión de cuadrantes)
- `User.pde` - Clase User (movimiento y comportamiento)
- `mostrarInfoOSC.pde` - Visualización de mensajes OSC en pantalla









