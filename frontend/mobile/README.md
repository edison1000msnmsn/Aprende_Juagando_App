# Frontend móvil

Cliente Flutter nativo de AprendeJugando. En el emulador Android se conecta a `10.0.2.2:3000`.

```powershell
flutter pub get
flutter run
```

Para cambiar el servidor:

```powershell
flutter run --dart-define=API_BASE_URL=http://IP_DEL_PC:3000/api/v1
```
