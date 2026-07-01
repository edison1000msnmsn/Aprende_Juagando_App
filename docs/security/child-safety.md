# Seguridad y protección infantil

El prototipo no pide datos personales, email infantil, cámara, micrófono, ubicación ni contactos. No tiene anuncios, compras, chat o rankings públicos. Los nombres demo son ficticios.

La zona adulta usa un desafío cognitivo como separación de UX, no como autenticación. En producción requiere sesión adulta real, RBAC, comprobación de propiedad de perfil, HTTPS, tokens rotativos en almacenamiento seguro y eliminación/exportación de datos.

El progreso local no debe usarse como fuente de verdad en producción. La API validará respuestas y recompensas sin enviar `correctAnswer` antes del intento. Los logs no incluirán tokens ni datos innecesarios del menor.
