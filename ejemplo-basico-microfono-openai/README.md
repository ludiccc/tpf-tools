# Ejemplo basico microfono + texto + OpenAI

Este ejemplo hace una version corta del recorrido:

microfono -> speech to text -> OpenAI -> respuesta en pantalla

Graba 5 segundos de audio, lo transcribe y manda ese texto a OpenAI. La respuesta se imprime en la terminal.

## Instalar

```bash
pip install -r requirements.txt
```

## API key

Antes de ejecutar hay que cargar la API key.

En macOS o Linux:

```bash
export OPENAI_API_KEY="tu_api_key"
```

En Windows PowerShell:

```powershell
$env:OPENAI_API_KEY="tu_api_key"
```

## Ejecutar

```bash
python microfono_openai.py
```

El programa espera Enter, graba 5 segundos y despues muestra:

- el texto reconocido
- la respuesta de OpenAI

## Para cambiar la duracion

Al principio del archivo esta esta linea:

```python
DURACION_SEGUNDOS = 5
```

Se puede cambiar por otro numero si hace falta grabar mas o menos tiempo.
