# Plan de pruebas

## Automatizadas actuales

- Validación de JSON, módulos, secuencia de niveles, tipos, feedback, recompensas, accesibilidad e IDs únicos.
- Presencia de cabeceras de seguridad y tipos MIME del servidor.
- Comprobación sintáctica de JavaScript durante CI.
- Compilación TypeScript del backend y pruebas Jest.
- Migración Prisma aplicada sobre PostgreSQL 16 y seed idempotente.
- Smoke test real: login → perfil → nivel → actividad → intento → progreso.
- Auditoría de dependencias de producción sin vulnerabilidades reportadas.
- `flutter analyze` sin observaciones y widget tests del cliente móvil.
- Compilación e instalación de APK debug en emulador Android 17.
- Flujo real en Android: login → home → actividad remota → feedback correcto.
- Mapa de niveles: disponibles, bloqueados y avance secuencial entre actividades.

## Exploratorias requeridas

1. Home en teléfonos Android pequeños, medianos y tablet.
2. Completar un reto en cada mundo.
3. Fallar una opción y confirmar que permite reintento sin perder progreso.
4. Recargar y confirmar estrellas/perfil/progreso persistentes.
5. Cambiar entre perfiles y confirmar que el progreso no se mezcla.
6. Probar TalkBack, tamaño de fuente grande y orientación horizontal.
7. Confirmar la dirección API mediante `--dart-define` en un teléfono físico.

Siguientes pruebas: integración automatizada login-perfil-actividad-progreso, autorización cruzada y cola offline.
