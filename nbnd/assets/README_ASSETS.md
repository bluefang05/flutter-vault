# Assets provisionales

El proyecto funciona con arte geométrico generado por código. La imagen del personaje, el icono y los WAV incluidos pueden sustituirse sin cambiar la lógica central.

## Barra de reserva con cucharas

La carpeta `assets/images/spoons/` contiene assets PNG transparentes listos para pantalla:

- `spoon_full.png`: 2 medias cucharas disponibles.
- `spoon_half.png`: 1 media cuchara disponible.
- `spoon_empty.png`: cuchara agotada.
- `spoon_panel.png`: fondo opcional para una barra horizontal.

El widget `lib/widgets/spoon_life_bar.dart` selecciona automáticamente el asset correcto según la reserva restante. Cada choque consume media cuchara y el personaje recibe aproximadamente un segundo de invulnerabilidad.

## Sustitución recomendada

- `assets/images/character_placeholder.png`: ilustración del personaje NBND.
- `assets/images/icon_nbnd.png`: icono propuesto de NBND.
- `assets/images/icon_placeholder.png`: base temporal anterior.
- `assets/audio/pulse.wav`: pulso o clic de navegación.
- `assets/audio/power.wav`: activación del poder.
- `assets/audio/hit.wav`: colisión.

Las rutas están registradas en `assets/data/asset_manifest.json`. Mantenerlas permite reemplazar los archivos sin modificar el código. La reproducción de audio sigue desacoplada para que el MVP compile sin otro plugin; puede integrarse después con `flame_audio`.
