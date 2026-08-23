$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host ""
Write-Host "PYME RD 0.2.0 - aplicando actualización" -ForegroundColor Cyan
Write-Host "Directorio: $PWD" -ForegroundColor DarkGray

if (-not (Test-Path ".\pubspec.yaml")) {
    throw "Ejecuta este script dentro de la carpeta del proyecto pymerd."
}

if (-not (Test-Path ".\android\app\src\main\kotlin\com\enmanuelapp\pymerd\MainActivity.kt")) {
    throw "Falta el MainActivity actualizado. Extrae nuevamente el ZIP con -Force."
}

flutter clean
flutter pub get
dart format lib test

Write-Host ""
Write-Host "Actualización aplicada. La base de datos se migrará al abrir la app." -ForegroundColor Green
Write-Host "Ejecuta: flutter run --release" -ForegroundColor Yellow
Write-Host "Comprobación opcional: flutter analyze" -ForegroundColor DarkGray
