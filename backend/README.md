# API AprendeJugando

API NestJS versionada en `/api/v1`. Swagger queda disponible en `/docs`.

```bash
docker compose up -d postgres
npm run db:generate
npm run db:migrate
npm run db:seed
npm run dev:api
```

Cuenta local de demostración: `familia@demo.local` / `DemoAprende123!`. No reutilizar en entornos remotos.

Flujo mínimo: `POST /auth/login` → `GET /profiles` → `GET /modules?profileId=...` → `GET /activities/:id?profileId=...` → `POST /activities/:id/attempts`.
