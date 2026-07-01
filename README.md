# AprendeJugando Kids

Vertical slice instalable y offline-first de una experiencia educativa para niñas y niños de 4 a 8 años. Esta primera entrega convierte el diseño de referencia en un producto navegable y prueba el flujo completo: elegir mundo, resolver una actividad, recibir feedback, ganar estrellas y revisar progreso.

## Inicio rápido

Requisito: Node.js 20 o superior. No hay dependencias de terceros.

```bash
npm start
```

Abre `http://127.0.0.1:4173`. Para validar la entrega:

```bash
npm run content:validate
npm test
```

## Funcionalidad disponible

- Home responsive con cuatro mundos y reto diario.
- Actividades interactivas de conteo, opción, letras, memoria y pintura.
- Feedback positivo, pistas y objetivos de 3 a 5 minutos.
- Progreso, estrellas, perfil y preferencias persistentes en el dispositivo.
- Zona adulta con desafío cognitivo, métricas, recomendación y privacidad.
- PWA instalable con caché offline de la interfaz.
- Contrato de contenido v1 y validador sin dependencias.
- Accesibilidad: navegación por teclado, objetivos táctiles grandes, contraste, semántica y movimiento reducido.

## Arquitectura y alcance

La carpeta de trabajo estaba vacía y el SDK de Flutter local no consiguió inicializarse. Por eso esta entrega implementa el vertical slice como PWA ejecutable, sin fingir que el backend o Flutter ya existen. La arquitectura objetivo del documento maestro sigue siendo Flutter + Riverpod + API NestJS + Prisma/PostgreSQL. Ver [system-context.md](docs/architecture/system-context.md) para el límite actual y el plan de migración.

```text
apps/web/                    PWA y servidor estático local
content/<area>/              Niveles versionados por integrante
packages/content-schema/     Contrato JSON y validador
docs/                        Arquitectura, producto, pruebas y seguridad
.github/workflows/           Validación continua
```

## Contenido colaborativo

Cada integrante trabaja únicamente en `content/<area>`. Los IDs siguen `area-lNN-aNN`; antes de abrir un PR se ejecuta `npm run content:validate`. No se deben incluir datos reales de menores ni medios sin licencia y texto alternativo.

## Próximo incremento técnico

1. Inicializar `apps/mobile` cuando el SDK Flutter responda y portar tokens/componentes.
2. Crear `apps/api` con NestJS, Prisma y PostgreSQL.
3. Mover validación de respuestas y recompensas al backend; el cliente nunca recibirá la respuesta correcta.
4. Agregar autenticación adulta, perfiles y sincronización idempotente de intentos.
5. Mantener esta PWA como preview de contenido o reemplazarla por un panel de autoría.
