$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host ""
Write-Host "PYME RD - finalizando integración AdMob" -ForegroundColor Cyan
Write-Host "Directorio: $PWD" -ForegroundColor DarkGray

if (-not (Test-Path ".\pubspec.yaml")) {
    throw "Ejecuta este script dentro de la carpeta raíz de pymerd."
}

$required = @(
    ".\lib\ads\ads_config.dart",
    ".\lib\widgets\pyme_ad_banner.dart",
    ".\lib\main.dart",
    ".\lib\screens\home_shell.dart",
    ".\android\app\src\main\AndroidManifest.xml"
)

foreach ($file in $required) {
    if (-not (Test-Path $file)) {
        throw "Falta el archivo requerido: $file"
    }
}

$pubspec = Get-Content ".\pubspec.yaml" -Raw
if ($pubspec -notmatch "google_mobile_ads:\s*5\.3\.1") {
    throw "pubspec.yaml no contiene google_mobile_ads 5.3.1."
}

$manifest = Get-Content ".\android\app\src\main\AndroidManifest.xml" -Raw
if ($manifest -notmatch "ca-app-pub-3322493998376707~6779988736") {
    throw "El AndroidManifest.xml no contiene el App ID de PYMERD."
}

$main = Get-Content ".\lib\main.dart" -Raw
if ($main -notmatch "MobileAds\.instance\.initialize") {
    throw "main.dart no inicializa MobileAds."
}

$home = Get-Content ".\lib\screens\home_shell.dart" -Raw
if ($home -notmatch "PymeAdBanner") {
    throw "home_shell.dart no usa el banner real."
}

flutter clean
flutter pub get
dart format lib\main.dart lib\screens\home_shell.dart lib\ads\ads_config.dart lib\widgets\pyme_ad_banner.dart
flutter analyze

Write-Host ""
Write-Host "Integración AdMob verificada." -ForegroundColor Green
Write-Host "Prueba con anuncios de Google de ejemplo:" -ForegroundColor Yellow
Write-Host "flutter run --release" -ForegroundColor White
Write-Host ""
Write-Host "Para el AAB oficial con el bloque real:" -ForegroundColor Yellow
Write-Host "flutter build appbundle --release --dart-define=PYMERD_LIVE_ADS=true" -ForegroundColor White
