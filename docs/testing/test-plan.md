# Plan de pruebas

## Automatizadas actuales

- Validación de JSON, módulos, secuencia de niveles, tipos, feedback, recompensas, accesibilidad e IDs únicos.
- Presencia de cabeceras de seguridad y tipos MIME del servidor.
- Comprobación sintáctica de JavaScript durante CI.

## Exploratorias requeridas

1. Home en 320, 390, 768 y 1280 px.
2. Completar un reto en cada mundo.
3. Fallar una opción y confirmar que permite reintento sin perder progreso.
4. Recargar y confirmar estrellas/perfil/progreso persistentes.
5. Desconectar red tras la primera carga y confirmar navegación base.
6. Navegar solo con teclado y con movimiento reducido.
7. Verificar que la zona adulta rechaza respuestas distintas de 13.

Cuando existan Flutter/API se agregarán widget tests, integración login-perfil-actividad-progreso, autorización cruzada e idempotencia de intentos.
