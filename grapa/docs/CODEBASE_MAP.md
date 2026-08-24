# Mapa técnico de Grapa

Este documento permite localizar cambios sin cargar toda la aplicación en contexto.

## Flujo principal

```text
main.dart
  GrapaApp
    GrapaHome / _GrapaHomeState
      IndexedStack
        0 -> _TodayView
        1 -> _AdventureView
        2 -> _PinView
        3 -> _ProfileView
             _ShopPreviewSection
      NavigationBar
```

`_GrapaHomeState` es el coordinador: carga y guarda preferencias, mantiene misiones/economía/racha/Pin y pasa valores y callbacks a vistas sin estado.

## Archivos y responsabilidades

| Archivo | Contenido |
|---|---|
| `lib/main.dart` | Imports, declaraciones `part`, `main()` y tema de `GrapaApp`. |
| `lib/src/models.dart` | `Mission`, serialización JSON y `MissionDraft`. |
| `lib/src/assets.dart` | Constantes de assets y selección de imágenes por progreso/estado. |
| `lib/src/home.dart` | Estado global local, SharedPreferences, cambio de día, CRUD de misiones, monedas, total ganado, racha, alimentar a Pin, ropa equipada y navegación. |
| `lib/src/home_mission_editor.dart` | Bottom sheet para crear y editar misiones. |
| `lib/src/today_view.dart` | Composición y scroll de la pantalla Hoy. |
| `lib/src/today_widgets.dart` | Estado vacío, hero, animación, recompensa, tarjeta de misión e indicadores. |
| `lib/src/adventure_view.dart` | Mapa de aventura, progreso y nodos. |
| `lib/src/pin_view.dart` | Escena de Pin, corazones, alimentación y casa. |
| `lib/src/profile_view.dart` | Estadísticas, progreso y Grapa equipada. |
| `lib/src/profile_shop_widgets.dart` | Vista previa de tienda, tarjetas de objetos y taller de mejoras. |
| `lib/src/common_widgets.dart` | `_ScenarioCard`, `_Stat` y `_InfoCard`. |
| `test/widget_test.dart` | Pruebas de misión, navegación, edición, eliminación y restauración diaria. |

## Estado persistido

Definido en `lib/src/home.dart`:

| Clave | Tipo | Propósito |
|---|---|---|
| `daily_missions` | JSON string | Lista y estado de misiones. |
| `daily_missions_date` | string | Día activo; permite reiniciar `done`. |
| `coins` | int | Monedas disponibles. |
| `total_coins_earned` | int | Monedas ganadas de por vida; fuente del nivel de perfil. |
| `streak` | int | Racha registrada. |
| `pin_hearts` | int | Corazones de Pin. |
| `last_completed_date` | string | Último día completado. |
| `daily_rewards_earned` | int | Monedas obtenidas por misiones durante el día. |
| `equipped_grapa_asset` | string | Asset actual de Grapa equipada. |
| `purchased_items` | List<string> | Identificadores de objetos comprados en la tienda. |
| `adventure_days_completed` | int | Días totales de expedición completados para la progresión por mundos. |
| `purchased_upgrades` | List<string> | Habilidades permanentes activas del taller (imán, gourmet). |
| `streak_shields` | int | Cantidad de escudos acumulados para proteger la racha. |
| `completed_dates_history` | List<string> | Registro de fechas completadas para el historial y calendario semanal. |

## Dependencias entre módulos

- Todas las vistas dependen de tipos/constantes de `models.dart` y `assets.dart` mediante la biblioteca compartida.
- Solo `home.dart` debe mutar el estado persistente.
- `today_widgets.dart` contiene widgets específicos de Hoy; `common_widgets.dart` solo contiene widgets realmente compartidos.
- `assets.dart` no carga imágenes: únicamente centraliza rutas y reglas de selección.

## Puntos frecuentes de cambio

- Nueva pestaña: estado `_tab`, `IndexedStack` y `NavigationDestination` en `home.dart`; vista nueva registrada en `main.dart`.
- Nuevo campo de misión: `models.dart`, migración tolerante en `Mission.fromJson`, editor/estado en `home.dart` y UI/pruebas correspondientes.
- Nueva imagen: carpeta bajo `assets/images`, declaración en `pubspec.yaml` si hace falta y constante en la clase apropiada de `assets.dart`.
- Banner publicitario persistente: integrar en el `Scaffold` de `home.dart`, encima de `NavigationBar`, reservando altura y sin superponer controles.
- Cambio de textos visibles: busca el texto con `rg` y actualiza las expectativas de `widget_test.dart` cuando corresponda.

## Invariantes funcionales

- Las misiones persisten entre aperturas y se desmarcan al cambiar de día.
- Las primeras cinco misiones completadas del día pagan 10 monedas cada una (máximo 50); las adicionales cuentan para progreso sin generar monedas.
- Descompletar una misión que pagó revierte sus 10 monedas y libera ese cupo, salvo que la misión haya sido eliminada.
- La racha se registra al completar todas las misiones no vacías.
- Alimentar a Pin cuesta 10 monedas y los corazones no deben superar 5.
- Alimentar a Pin no debe cobrar si ya está comiendo o si tiene 5 corazones.
- El nivel del perfil depende de `total_coins_earned`, no de `coins`, para que comprar/usar monedas no baje nivel.
- La ropa equipada de Grapa debe existir en `GrapaEquippedAssets.all`; si una preferencia vieja apunta a otra ruta, se usa el vestido premium.
- `IndexedStack` conserva el estado visual de cada pestaña.

## Validación mínima

```powershell
dart format lib test
flutter analyze
flutter test
```

Para cambios de persistencia añade una prueba con `SharedPreferences.setMockInitialValues`. Para cambios visuales prueba también una ventana estrecha y escalado de texto.
