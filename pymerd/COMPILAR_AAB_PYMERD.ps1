$ErrorActionPreference = 'Stop'

if (-not (Test-Path 'pubspec.yaml')) {
    throw 'Ejecuta este script desde la carpeta raiz de pymerd.'
}

Write-Host 'Compilando AAB oficial de PYME RD con el bloque AdMob real...'
flutter build appbundle --release --dart-define=PYMERD_LIVE_ADS=true
if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar el AAB.' }

$path = Resolve-Path 'build\app\outputs\bundle\release\app-release.aab'
Write-Host ''
Write-Host 'AAB generado:' -ForegroundColor Green
Write-Host $path
