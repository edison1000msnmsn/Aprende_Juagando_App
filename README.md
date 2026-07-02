# AprendeJugando Kids

Base full-stack instalable y offline-first para una experiencia educativa dirigida a niñas y niños de 4 a 8 años. Incluye PWA responsive, API NestJS/Fastify, PostgreSQL, Prisma y contenido educativo versionado.

## Inicio rápido

Requisitos: Node.js 20 o superior y Docker Desktop.

```bash
npm install
docker compose up -d postgres
npm run db:generate
npm run db:migrate
npm run db:seed
npm run dev:api
```

En otra terminal:

```bash
npm start
```

Abre `http://127.0.0.1:8080` (o el puerto indicado por la terminal). Swagger está en `http://127.0.0.1:3000/docs`.

También puedes levantar PostgreSQL + API en contenedores con `docker compose up --build`. Para validar:

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
- Registro/login adulto, JWT de acceso y refresh token rotativo hasheado.
- Perfiles infantiles subordinados a la cuenta adulta y autorización por propietario.
- Módulos/niveles publicados servidos dinámicamente desde PostgreSQL.
- Intentos idempotentes, respuestas ocultas, XP/estrellas calculados por el backend.
- Cola local de intentos cuando se pierde la conexión.
- Contrato de contenido v1 y validador sin dependencias.
- Accesibilidad: navegación por teclado, objetivos táctiles grandes, contraste, semántica y movimiento reducido.

## Arquitectura y alcance

La carpeta de trabajo estaba vacía y el SDK de Flutter local no consiguió inicializarse. Esta entrega implementa el cliente como PWA y completa el vertical slice de backend y base de datos. Flutter + Riverpod permanece como cliente móvil futuro; la API y los contratos ya son reutilizables por ese cliente.

```text
apps/web/                    PWA y servidor estático local
apps/api/                    NestJS + Fastify + Prisma
content/<area>/              Niveles versionados por integrante
packages/content-schema/     Contrato JSON y validador
docs/                        Arquitectura, producto, pruebas y seguridad
.github/workflows/           Validación continua
```

## Contenido colaborativo

Cada integrante trabaja únicamente en `content/<area>`. Los IDs siguen `area-lNN-aNN`; antes de abrir un PR se ejecuta `npm run content:validate`. No se deben incluir datos reales de menores ni medios sin licencia y texto alternativo.

## Cuenta demo local

`familia@demo.local` / `DemoAprende123!`. Solo para desarrollo local.

## Próximos incrementos

1. Portar la PWA a Flutter cuando el SDK local responda.
2. Agregar panel editorial DRAFT → REVIEW → PUBLISHED.
3. Incorporar almacenamiento multimedia S3-compatible.
4. Añadir recuperación de contraseña, verificación de email y cierre global de sesiones.
