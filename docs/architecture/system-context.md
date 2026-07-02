# Contexto del sistema

## Estado implementado

```mermaid
flowchart LR
  Kid["Experiencia infantil"] --> PWA["PWA AprendeJugando"]
  Adult["Zona adulta"] --> PWA
  PWA --> API["NestJS / Fastify"]
  API --> Prisma["Prisma ORM"]
  Prisma --> DB["PostgreSQL"]
  PWA --> Local["Caché y cola offline"]
  PWA --> Cache["Service Worker / offline"]
  Author["Equipo de contenido"] --> JSON["Niveles JSON v1"]
  JSON --> Validator["Validador de contenido"]
```

El vertical slice valida el flujo adulto → perfil → contenido → intento → progreso. La API es autoridad de respuestas y recompensas; la PWA usa almacenamiento local solo para preferencias y cola offline.

## Arquitectura móvil objetivo

```mermaid
flowchart LR
  Flutter["Flutter / Riverpod"] --> API["NestJS REST /api/v1"]
  Flutter --> Hive["Hive + pending_sync"]
  API --> Prisma["Prisma"]
  Prisma --> DB["PostgreSQL"]
  API --> Storage["Storage S3 compatible"]
  Content["JSON validado"] --> API
```

El backend será autoridad de respuestas, recompensas, permisos, publicación e idempotencia. Flutter renderizará contratos publicados y guardará intentos offline con `clientAttemptId`.

## Decisiones

- Contrato `schemaVersion: 1` para congelar la forma inicial antes de crear contenido masivo.
- Contenido separado del progreso individual.
- IDs por área para reducir conflictos entre integrantes.
- Feedback neutral ante errores; sin rachas punitivas ni rankings.
- Objetivos táctiles mínimos de 56 px y una acción principal por reto.
