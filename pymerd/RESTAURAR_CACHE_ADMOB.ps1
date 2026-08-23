$ErrorActionPreference = "Stop"
$Project = "C:\Users\manue\OneDrive\Desktop\proyectos\flutter\pymerd"
$CacheRoot = if ($env:PUB_CACHE) {
    $env:PUB_CACHE
} else {
    Join-Path $env:LOCALAPPDATA "Pub\Cache"
}
$GradleFile = Join-Path $CacheRoot "hosted\pub.dev\google_mobile_ads-5.3.1\android\build.gradle"

$backups = Get-ChildItem (Join-Path $Project "_backups") -Directory -Filter "admob_cache_*" |
    Sort-Object Name -Descending

if (-not $backups) {
    throw "No se encontro un respaldo admob_cache_*."
}

$source = Join-Path $backups[0].FullName "google_mobile_ads_build.gradle.original"
if (-not (Test-Path $source)) {
    throw "El respaldo mas reciente no contiene el archivo original."
}

Copy-Item $source $GradleFile -Force
Write-Host "Archivo original restaurado desde:" -ForegroundColor Green
Write-Host $source
