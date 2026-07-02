# Base de datos

Esta carpeta contiene la fuente de verdad de PostgreSQL:

- `prisma/schema.prisma`: modelos y relaciones.
- `prisma/migrations/`: historial versionado.
- `prisma/seed.ts`: importación idempotente de perfiles demo y `content/<area>`.

Comandos desde la raíz:

```powershell
docker compose up -d postgres
npm run db:generate
npm run db:migrate
npm run db:seed
```
