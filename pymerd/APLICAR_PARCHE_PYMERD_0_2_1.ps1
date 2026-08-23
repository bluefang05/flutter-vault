$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Aplicando parche PYMERD 0.2.1..." -ForegroundColor Cyan

if (-not (Test-Path "pubspec.yaml")) {
    throw "Ejecuta este script desde la carpeta raiz del proyecto pymerd."
}

flutter clean
flutter pub get
dart format lib/screens/inventory_page.dart

Write-Host ""
Write-Host "Parche aplicado. Compilando en release..." -ForegroundColor Green
flutter run --release
