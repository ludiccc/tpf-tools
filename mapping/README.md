# Herramientas de Mapping

Este repositorio reúne tres herramientas hechas en **Processing** para trabajar con **video mapping usando una webcam**. Las tres comparten una idea simple: tomar la imagen de cámara, definir qué parte nos interesa y decidir cómo se muestra en pantalla.

Las herramientas fueron pensadas para cubrir tres necesidades distintas:

- ajustar solo la **entrada** de cámara
- ajustar solo la **salida** proyectada
- ajustar **entrada y salida al mismo tiempo**

## Idea general

Cada sketch trabaja con **4 vértices** que forman un cuadrilátero.

- En el **mapping de entrada**, esos vértices recortan o redefinen qué zona de la webcam se usa como textura.
- En el **mapping de salida**, esos vértices determinan dónde se dibuja esa textura en la pantalla.
- En la herramienta combinada, una cuadrícula de entrada se relaciona con otra de salida para hacer la transformación completa.

Las coordenadas se guardan en archivos `.json`, así que la calibración queda persistida entre ejecuciones.

## Requisitos

- [Processing](https://processing.org/)
- La librería de video de Processing: `processing.video.*`
- Una webcam conectada y disponible

Si no se detecta ninguna cámara, los sketches muestran el mensaje `No se encontro una webcam.`

## Estructura del proyecto

- [mapping_in/mapping_in.pde](mapping_in/mapping_in.pde): herramienta para editar la entrada
- [mapping_in/mapping_in.json](mapping_in/mapping_in.json): configuración guardada de entrada
- [mapping_out/mapping_out.pde](mapping_out/mapping_out.pde): herramienta para editar la salida
- [mapping_out/mapping_out.json](mapping_out/mapping_out.json): configuración guardada de salida
- [mapping_in_mapping_out/mapping_in_mapping_out.pde](mapping_in_mapping_out/mapping_in_mapping_out.pde): herramienta combinada
- [mapping_in_mapping_out/mapping_in_mapping_out.json](mapping_in_mapping_out/mapping_in_mapping_out.json): configuración guardada combinada

## 1. `mapping_in`

Esta herramienta sirve para **calibrar la entrada de video**. En otras palabras, permite elegir qué sector de la imagen capturada por la webcam se va a usar.

### Qué hace

- Toma la señal de la cámara.
- Permite editar cuatro esquinas sobre la imagen original.
- Usa esas esquinas como coordenadas de textura.
- Estira esa selección para ocupar toda la ventana.

Esto resulta útil cuando la cámara está viendo una superficie en perspectiva y queremos “enderezar” o aislar una región específica.

### Cómo se ve

- En modo normal, muestra la imagen ya mapeada ocupando toda la ventana.
- En modo edición, muestra la cámara completa con el polígono de referencia y los handles para mover cada vértice.

### Controles

- `i`: entrar o salir del modo edición de input
- `1`, `2`, `3`, `4`: seleccionar un vértice
- `mouse`: arrastrar el vértice seleccionado
- `flechas`: ajuste fino del vértice
- `s`: guardar la configuración en `mapping_in.json`

### Archivo de configuración

`mapping_in.json` guarda un arreglo `input` con cuatro puntos normalizados entre `0` y `1`:

```json
{
  "input": [
    { "x": 0.15, "y": 0.15 },
    { "x": 0.85, "y": 0.15 },
    { "x": 0.85, "y": 0.85 },
    { "x": 0.15, "y": 0.85 }
  ]
}
```

## 2. `mapping_out`

Esta herramienta sirve para **calibrar la salida**. No modifica qué parte de la cámara se toma, sino **dónde y con qué deformación se dibuja la imagen en pantalla**.

### Qué hace

- Toma la señal completa de la webcam como textura.
- Permite mover cuatro esquinas sobre la pantalla.
- Dibuja la imagen dentro de ese cuadrilátero.

Es la herramienta indicada cuando queremos adaptar la proyección a una pared, maqueta, objeto irregular o superficie no rectangular.

### Cómo se ve

- Siempre muestra la imagen proyectada con la deformación aplicada.
- Cuando el modo edición está activo, además aparece el polígono de salida con sus handles.

### Controles

- `o`: entrar o salir del modo edición de output
- `1`, `2`, `3`, `4`: seleccionar un vértice
- `mouse`: arrastrar el vértice seleccionado
- `flechas`: ajuste fino del vértice
- `s`: guardar la configuración en `mapping_out.json`

### Archivo de configuración

`mapping_out.json` guarda un arreglo `output` con cuatro puntos normalizados:

```json
{
  "output": [
    { "x": 0.08, "y": 0.08 },
    { "x": 0.92, "y": 0.08 },
    { "x": 0.92, "y": 0.92 },
    { "x": 0.08, "y": 0.92 }
  ]
}
```

## 3. `mapping_in_mapping_out`

Esta es la herramienta más completa. Permite **editar la entrada y la salida dentro del mismo sketch**.

### Qué hace

- Carga una cuadrícula de `input` y otra de `output`.
- Usa los puntos de `input` para decidir qué parte de la cámara se samplea.
- Usa los puntos de `output` para decidir dónde se dibuja ese contenido en pantalla.
- Permite alternar entre modo presentación, edición de input y edición de output.

Es la opción más práctica cuando queremos resolver la calibración completa en una sola aplicación.

### Modos de trabajo

- `MODO_PRESENTAR`: muestra el resultado final
- `MODO_EDITAR_INPUT`: muestra la cámara completa para ajustar la entrada
- `MODO_EDITAR_OUTPUT`: muestra el resultado proyectado para ajustar la salida

### Controles

- `i`: entrar o salir del modo edición de input
- `o`: entrar o salir del modo edición de output
- `1`, `2`, `3`, `4`: seleccionar un vértice
- `mouse`: arrastrar el vértice seleccionado
- `flechas`: ajuste fino del vértice
- `s`: guardar la configuración en `mapping_in_mapping_out.json`

### Archivo de configuración

El archivo combinado guarda ambos conjuntos de puntos:

```json
{
  "input": [
    { "x": 0.15, "y": 0.15 },
    { "x": 0.85, "y": 0.15 },
    { "x": 0.85, "y": 0.85 },
    { "x": 0.15, "y": 0.85 }
  ],
  "output": [
    { "x": 0.08, "y": 0.08 },
    { "x": 0.92, "y": 0.08 },
    { "x": 0.92, "y": 0.92 },
    { "x": 0.08, "y": 0.92 }
  ]
}
```

## Flujo de uso recomendado

Una forma simple de trabajar es esta:

1. Abrir `mapping_in` si primero queremos definir qué parte de la cámara nos interesa.
2. Abrir `mapping_out` si después queremos adaptar la proyección a una superficie específica.
3. Usar `mapping_in_mapping_out` cuando necesitemos hacer ambas calibraciones sin salir del mismo sketch.
4. Guardar siempre con `s` una vez terminados los ajustes.

## Diferencias entre las tres herramientas

| Herramienta | Ajusta entrada | Ajusta salida | Uso principal |
| --- | --- | --- | --- |
| `mapping_in` | Sí | No | Recortar o corregir la región tomada por la cámara |
| `mapping_out` | No | Sí | Deformar la proyección sobre la pantalla o superficie |
| `mapping_in_mapping_out` | Sí | Sí | Resolver la calibración completa en una sola app |

## Nota técnica

Los vértices se guardan en coordenadas normalizadas entre `0` y `1`. Eso permite que la configuración sea independiente de la resolución exacta de la ventana o de la pantalla, aunque visualmente la calibración final siempre depende del dispositivo y del encuadre real de la cámara.

## Posibles usos

- pruebas de video mapping
- prototipos para instalaciones audiovisuales
- calibración de cámara y proyección
- experimentación con superficies deformadas o no planas

