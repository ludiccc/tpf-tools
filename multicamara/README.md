# Multicamara con OpenCV

Este sketch abre dos camaras con la misma resolucion (`640x480`) y muestra sus imagenes una al lado de la otra. Permite seleccionar cuatro esquinas de entrada y corregir la perspectiva para que el cuadrilatero ocupe nuevamente un rectangulo de `640x480`.

## Instalar

```bash
pip install -r requirements.txt
```

## Ejecutar

```bash
python multicamara.py
```

Las camaras deben aparecer como los dispositivos `0` y `1` de OpenCV. Ambas deben aceptar la resolucion `640x480`; si una no la entrega, el programa termina para evitar que las vistas queden desparejas.

## Controles

- `1` / `2`: seleccionar la camara que se quiere modificar.
- `e`: entrar en modo edicion para la camara seleccionada.
- Mouse: arrastrar los handles numerados. El orden es arriba izquierda, arriba derecha, abajo derecha, abajo izquierda.
- `Enter`: aplicar la correccion de perspectiva y volver a la vista normal.
- `p`: alternar la imagen pixelada/no pixelada.
- `r`: restablecer las esquinas de la camara seleccionada.
- `q` o `Esc`: salir.

La correccion usa `cv2.getPerspectiveTransform` y `cv2.warpPerspective`: el cuadrilatero elegido se transforma en todo el rectangulo de salida `640x480`.

Al presionar `Enter`, las esquinas de las dos camaras se guardan en `multicamara.json`, dentro de esta misma carpeta. El archivo se carga automaticamente al iniciar la aplicacion, por lo que las correcciones confirmadas quedan activas entre ejecuciones.
