import os
import tempfile

import numpy as np
import sounddevice as sd
import soundfile as sf
from openai import OpenAI


DURACION_SEGUNDOS = 5
SAMPLERATE = 16000
CANALES = 1

PROMPT = """
Responde en castellano, de forma breve y clara.
La persona que te habla es estudiante y acaba de decir algo por microfono.
"""

PROMPT = """
Eres un experto en interpretar el contenido. Necesito que clasifiques el mensaje que te voy a dar en tres estados emocionales: alegre, triste o neutro y me des un porcentaje de cada uno.

Devuelve SOLO un JSON en el siguiente formato:
{
  "alegre": 0.33,
  "triste": 0.33,
  "neutro": 0.34,
  "explicacion": "Aquí puedes incluir una breve explicación de por qué has clasificado el mensaje de esa manera."
}
Rules:
- Solo provee de un JSON con los tres estados emocionales: alegre, triste o neutro y la explicación de por qué has clasificado el mensaje de esa manera en el campo "explicacion". No incluyas ningún otro texto fuera del JSON.
"""


if not os.getenv("OPENAI_API_KEY"):
    raise RuntimeError("Falta OPENAI_API_KEY. Hay que cargarla antes de correr el ejemplo.")

client = OpenAI()

input("Presiona Enter y habla durante 5 segundos...")

print("Grabando...")
audio = sd.rec(
    int(DURACION_SEGUNDOS * SAMPLERATE),
    samplerate=SAMPLERATE,
    channels=CANALES,
    dtype="int16",
)
sd.wait()
print("Listo. Procesando audio...")

archivo = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
sf.write(archivo.name, audio, SAMPLERATE)

with open(archivo.name, "rb") as audio_wav:
    transcripcion = client.audio.transcriptions.create(
        model="whisper-1",
        file=audio_wav,
        language="es",
    )

texto = transcripcion.text

print("\nTexto reconocido:")
print(texto)

respuesta = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": PROMPT},
        {"role": "user", "content": texto},
    ],
)

print("\nRespuesta de OpenAI:")
print(respuesta.choices[0].message.content)
