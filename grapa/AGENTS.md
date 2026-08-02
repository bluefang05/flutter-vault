# Grapa: guía rápida para agentes

Lee primero este archivo y abre únicamente los archivos indicados para la tarea. El mapa ampliado está en `docs/CODEBASE_MAP.md`.

## Enrutamiento de contexto

| Si vas a cambiar... | Lee primero |
|---|---|
| Arranque, tema o registro de módulos | `lib/main.dart` |
| Modelo/JSON de misiones | `lib/src/models.dart` |
| Rutas de imágenes o inferencia de categoría | `lib/src/assets.dart` (busca la clase concreta; no leas todo) |
| Estado, monedas, racha, persistencia, navegación o Pin | `lib/src/home.dart` |
| Formulario de crear/editar misión | `lib/src/home_mission_editor.dart` |
| Pantalla Hoy/lista de misiones | `lib/src/today_view.dart` |
| Tarjetas, animación y widgets de Hoy | `lib/src/today_widgets.dart` |
| Aventura | `lib/src/adventure_view.dart` |
| Pin | `lib/src/pin_view.dart` |
| Perfil/progreso | `lib/src/profile_view.dart` |
| Tienda del perfil | `lib/src/profile_shop_widgets.dart` |
| Widgets usados por varias pantallas | `lib/src/common_widgets.dart` |
| Pruebas y textos esperados | `test/widget_test.dart` |

## Reglas que evitan regresiones

- Los archivos de `lib/src/` son `part of '../main.dart'`; registra cada archivo nuevo con `part` en `lib/main.dart`.
- Conserva las clases privadas (`_Clase`): todas pertenecen a la misma biblioteca.
- La fuente de verdad del estado está en `_GrapaHomeState`; las vistas reciben datos y callbacks.
- Las claves persistidas están al inicio de `home.dart`. No las renombres sin migración.
- No edites ni reorganices imágenes para una tarea de lógica/UI que no lo requiera.
- Después de cambios Dart ejecuta `dart format lib test`, `flutter analyze` y `flutter test`.
- Mantén los archivos preferiblemente por debajo de 500 líneas; separa por pantalla o responsabilidad, no por cada widget pequeño.

## Comandos rápidos

```powershell
flutter analyze
flutter test
rg -n "texto_o_simbolo" lib test
```
