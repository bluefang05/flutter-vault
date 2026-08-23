$ErrorActionPreference = "Stop"

Write-Host "Aplicando package final de Voxel Anaconda..." -ForegroundColor Cyan

$oldPath = "android\app\src\main\kotlin\com\example\voxel_anaconda"
if (Test-Path $oldPath) {
    Remove-Item $oldPath -Recurse -Force
    Write-Host "Eliminada MainActivity del package temporal." -ForegroundColor Yellow
}

Write-Host "Package final: com.enmanuelapps.voxelanaconda" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora ejecuta:"
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter run --release"
