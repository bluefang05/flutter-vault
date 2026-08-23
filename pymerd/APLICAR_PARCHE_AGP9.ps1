$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "" 
Write-Host "PYME RD - parche AGP 9 y MainActivity" -ForegroundColor Cyan

if (-not (Test-Path ".\pubspec.yaml")) {
    throw "Ejecuta este script dentro de la carpeta raíz del proyecto pymerd."
}

$oldMain = ".\android\app\src\main\kotlin\com\example\pymerd\MainActivity.kt"
if (Test-Path $oldMain) {
    Remove-Item $oldMain -Force
    Write-Host "MainActivity anterior eliminado." -ForegroundColor DarkGray
}

if (-not (Test-Path ".\android\app\src\main\kotlin\com\enmanuelapp\pymerd\MainActivity.kt")) {
    throw "No se encontró el nuevo MainActivity. Extrae el ZIP en la raíz de pymerd con -Force."
}

flutter clean
flutter pub get
flutter run --release
