// main.js — lógica principal del proyecto

// Este archivo se carga al final del body, por lo que
// el DOM ya está disponible cuando se ejecuta.

// --- Ejemplo: mostrar un mensaje al hacer clic en una tarjeta ---
document.querySelectorAll(".tarjeta").forEach(function (tarjeta) {
  tarjeta.addEventListener("click", function () {
    alert("Hiciste clic en: " + tarjeta.textContent);
  });
});
