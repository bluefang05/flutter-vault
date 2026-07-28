# NBND — MVP Flutter/Flame

Juego radial minimalista para Android. La persona jugadora gira alrededor de un núcleo y esquiva anillos con aberturas. La neurodivergencia elegida cambia patrones, información visible y poder activo.

## Incluido

- TDAH: hiperfoco que ralentiza el mundo.
- TEA: patrones regulares, previsualización y congelación de rotación.
- TLP: resonancia por roces cercanos y onda que empuja los obstáculos.
- TID: dos aberturas/perspectivas y salto al punto opuesto.
- TOC: secuencias regulares y alineación de una abertura.
- TAG: predicción y retroceso automático/manual.
- Fases PULSO, RESONANCIA y FRACTURA.
- Modo práctica, reducción de destellos, vibración, récord local.
- Franja superior simulada para que una futura publicidad no cubra el juego.
- Assets provisionales reemplazables.

## Preparación en Windows

Este paquete contiene todo el código y los assets. Como el entorno que lo generó no tenía instalado Flutter, la carpeta nativa `android/` se crea en tu PC mediante el script:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\bootstrap_windows.ps1
```

Después:

```powershell
flutter run
```

## Preparación en Linux/macOS

```bash
chmod +x tool/bootstrap_unix.sh
./tool/bootstrap_unix.sh
flutter run
```

## Compatibilidad Android

Objetivo actual: Android API 21.

## Publicidad

`TopAdPlaceholder` reserva 50 px arriba y mantiene la arena libre. No hay AdMob activo en esta versión.

## Assets

Consulta `assets/README_ASSETS.md`. El juego central es geométrico y funciona aunque después se cambie toda la identidad visual.

## Validación pendiente

Ejecutar en una máquina con Flutter:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Identificador sugerido

`com.enmanuelapp.nbnd`
