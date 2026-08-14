$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Brote Cero - instalador de icono ===" -ForegroundColor Cyan
Write-Host ""

$projectRoot = (Get-Location).Path
$manifest = Join-Path $projectRoot "android\app\src\main\AndroidManifest.xml"
if (-not (Test-Path $manifest)) {
    throw "No parece que estes en la raiz del proyecto Flutter. Ejecuta este script desde la carpeta brote_cero."
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = Join-Path $projectRoot "backup_icono_$stamp"
New-Item -ItemType Directory -Force -Path $backup | Out-Null

$folders = @(
    "mipmap-mdpi",
    "mipmap-hdpi",
    "mipmap-xhdpi",
    "mipmap-xxhdpi",
    "mipmap-xxxhdpi"
)

foreach ($folder in $folders) {
    $targetDir = Join-Path $projectRoot "android\app\src\main\res\$folder"
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    foreach ($name in @("ic_launcher.png", "ic_launcher_round.png")) {
        $existing = Join-Path $targetDir $name
        if (Test-Path $existing) {
            $backupDir = Join-Path $backup $folder
            New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
            Copy-Item $existing (Join-Path $backupDir $name) -Force
        }

        $source = Join-Path $PSScriptRoot "android_res\$folder\$name"
        Copy-Item $source $existing -Force
    }
}

# Ensure manifest uses the launcher icon, and add roundIcon if missing.
$content = Get-Content $manifest -Raw
if ($content -notmatch 'android:icon="@mipmap/ic_launcher"') {
    $content = $content -replace '<application', '<application android:icon="@mipmap/ic_launcher"'
}
if ($content -notmatch 'android:roundIcon=') {
    $content = $content -replace 'android:icon="@mipmap/ic_launcher"', 'android:icon="@mipmap/ic_launcher"`r`n        android:roundIcon="@mipmap/ic_launcher_round"'
}
Set-Content -Path $manifest -Value $content -Encoding UTF8

Write-Host "Icono instalado." -ForegroundColor Green
Write-Host "Backup: $backup" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Cyan
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter run"
Write-Host ""
Write-Host "Para Play Store usa: play_store\brote_cero_icon_512.png"
