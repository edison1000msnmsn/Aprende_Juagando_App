# Contribuir

Usa ramas `content/<area>-levels`, `feature/<alcance>` o `fix/<alcance>`. Mantén cada cambio pequeño y ejecuta:

```bash
npm run content:validate
npm test
cd frontend/mobile
flutter analyze
flutter test
```

Los PR de contenido deben indicar objetivo pedagógico, rango de edad, nivel, capturas, resultado del validador y fuentes/licencias de medios. No modifiques el motor al agregar un nivel. Evita nombres completos, fotos, ubicaciones o cualquier dato real de menores.

Antes de trabajar contenido ejecuta `docker compose up -d postgres`, `npm run db:migrate` y `npm run db:seed`. Cada integrante modifica solo `content/<area>`; el seed importa esos archivos a PostgreSQL sin editar el motor.

Commits recomendados: `feat:`, `fix:`, `content:`, `docs:`, `test:` y `chore:`.
