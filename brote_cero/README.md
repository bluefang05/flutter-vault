# Brote Cero - parche de icono

Este ZIP reemplaza el icono launcher de Android por el icono rojo/negro de Brote Cero.

## Instalacion

1. Copia el ZIP a la raiz de tu proyecto `brote_cero`.
2. Descomprimelo.
3. Desde PowerShell, estando en la raiz del proyecto, ejecuta:

```powershell
powershell -ExecutionPolicy Bypass -File .\brote_cero_icon_patch\instalar_icono.ps1
flutter clean
flutter pub get
flutter run
```

El instalador:
- crea una copia de seguridad de los iconos anteriores;
- reemplaza `ic_launcher.png` e `ic_launcher_round.png` en todas las densidades Android;
- asegura que `AndroidManifest.xml` use esos iconos;
- no cambia el minSdk ni otras partes del proyecto.

Para Google Play:
- `play_store/brote_cero_icon_512.png` es el icono de 512x512.
- `play_store/brote_cero_icon_1024.png` queda como maestro de alta resolucion.
