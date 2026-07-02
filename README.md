# AprendeJugando Kids

Aplicación móvil educativa para niñas y niños de 4 a 8 años. El producto está dividido en cliente Flutter, API NestJS y PostgreSQL/Prisma.

## Estructura

```text
frontend/mobile/             Aplicación Flutter para Android
frontend/web-preview/        Referencia visual web
backend/                     API NestJS + Fastify
database/prisma/             Esquema, migraciones y seed PostgreSQL
content/<area>/              Niveles versionados por integrante
packages/content-schema/     Contrato y validador de contenido
docs/                        Arquitectura, pruebas y seguridad
```

## Ejecutar en Android Studio

Requisitos: Flutter 3.41 o superior, Android Studio, Android SDK, Node.js 20 y Docker Desktop.

1. Inicia el backend y PostgreSQL desde la raíz:

```powershell
npm install
docker compose up -d --build
```

2. Abre `frontend/mobile` en Android Studio.
3. Inicia un emulador Android.
4. En una terminal dentro de `frontend/mobile` ejecuta:

```powershell
flutter pub get
flutter run
```

El emulador usa por defecto `http://10.0.2.2:3000/api/v1`. Para un teléfono físico conectado a la misma red, usa la IP local de la computadora:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:3000/api/v1
```

Reemplaza `192.168.1.50` por la IP real de la computadora y permite el puerto 3000 en el firewall.

## Cuenta demo

```text
Correo: familia@demo.local
Contraseña: DemoAprende123!
```

Swagger está disponible en `http://127.0.0.1:3000/docs` y el health check en `http://127.0.0.1:3000/api/v1/health`.

## Funcionalidad

- Inicio de sesión adulto y almacenamiento seguro de sesión.
- Selección de perfiles infantiles.
- Cuatro mundos servidos desde PostgreSQL.
- Mapa de niveles con desbloqueo progresivo y múltiples actividades por nivel.
- Actividades nativas de conteo, palabras, memoria y pintura.
- Respuestas y recompensas validadas exclusivamente por el backend.
- Intentos idempotentes, estrellas y progreso por perfil.
- Interfaz adaptable con objetivos táctiles grandes y feedback positivo.

## Validación

```powershell
npm run build:api
npm test
npm run content:validate
cd frontend/mobile
flutter analyze
flutter test
flutter build apk --debug
```

## Trabajo colaborativo de niveles

Cada integrante modifica únicamente `content/<area>`. Los IDs siguen `area-lNN-aNN`. Antes de abrir un PR se ejecutan `npm run content:validate` y `npm run db:seed`.
