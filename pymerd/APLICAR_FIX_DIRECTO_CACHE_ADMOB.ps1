$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Project = "C:\Users\manue\OneDrive\Desktop\proyectos\flutter\pymerd"
$Pubspec = Join-Path $Project "pubspec.yaml"
$CacheRoot = if ($env:PUB_CACHE) {
    $env:PUB_CACHE
} else {
    Join-Path $env:LOCALAPPDATA "Pub\Cache"
}
$Plugin = Join-Path $CacheRoot "hosted\pub.dev\google_mobile_ads-5.3.1"
$GradleFile = Join-Path $Plugin "android\build.gradle"

if (-not (Test-Path $Pubspec)) {
    throw "No se encontro PYMERD en $Project"
}

if (-not (Test-Path $GradleFile)) {
    Push-Location $Project
    try {
        flutter pub get
        if ($LASTEXITCODE -ne 0) {
            throw "flutter pub get fallo."
        }
    } finally {
        Pop-Location
    }
}

if (-not (Test-Path $GradleFile)) {
    throw "No se encontro $GradleFile"
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupDir = Join-Path $Project "_backups\admob_cache_$timestamp"
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
Copy-Item $GradleFile (Join-Path $BackupDir "google_mobile_ads_build.gradle.original") -Force

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " PYMERD - FIX DIRECTO GOOGLE_MOBILE_ADS 5.3.1" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Archivo: $GradleFile"
Write-Host "Backup:  $BackupDir"
Write-Host ""

$text = Get-Content $GradleFile -Raw
$old = "for (def configuration : configurations.all) {"
$new = "for (def configuration : configurations) {"

if ($text.Contains($old)) {
    $text = $text.Replace($old, $new)
    [System.IO.File]::WriteAllText(
        $GradleFile,
        $text,
        (New-Object System.Text.UTF8Encoding($false))
    )
    Write-Host "Linea incompatible corregida." -ForegroundColor Green
} elseif ($text.Contains($new)) {
    Write-Host "La correccion ya estaba aplicada." -ForegroundColor Yellow
} else {
    throw "No se encontro la linea conocida en el build.gradle del plugin."
}

$check = Get-Content $GradleFile -Raw
if ($check.Contains("configurations.all")) {
    throw "La expresion configurations.all sigue presente."
}
if (-not $check.Contains($new)) {
    throw "No se pudo verificar la linea corregida."
}

# Normalizar pubspec para usar la versión alojada ya corregida en caché.
$pubspecText = Get-Content $Pubspec -Raw
$pathBlock = "(?ms)^[ ]{2}google_mobile_ads\s*:\s*\r?\n[ ]{4}path\s*:[^\r\n]*$"
$singleLine = "(?m)^[ ]{2}google_mobile_ads\s*:\s*[^\r\n]*$"

if ($pubspecText -match $pathBlock) {
    $pubspecText = [regex]::Replace(
        $pubspecText,
        $pathBlock,
        "  google_mobile_ads: 5.3.1",
        1
    )
} elseif ($pubspecText -match $singleLine) {
    $pubspecText = [regex]::Replace(
        $pubspecText,
        $singleLine,
        "  google_mobile_ads: 5.3.1",
        1
    )
} elseif ($pubspecText -match "(?m)^dependencies:\s*$") {
    $pubspecText = [regex]::Replace(
        $pubspecText,
        "(?m)^dependencies:\s*$",
        "dependencies:`r`n  google_mobile_ads: 5.3.1",
        1
    )
} else {
    throw "No se encontro la seccion dependencies en pubspec.yaml."
}

[System.IO.File]::WriteAllText(
    $Pubspec,
    $pubspecText,
    (New-Object System.Text.UTF8Encoding($false))
)

$Overrides = Join-Path $Project "pubspec_overrides.yaml"
if (Test-Path $Overrides) {
    $overrideText = Get-Content $Overrides -Raw
    if ($overrideText -match "google_mobile_ads") {
        Copy-Item $Overrides (Join-Path $BackupDir "pubspec_overrides.yaml") -Force
        Remove-Item $Overrides -Force
        Write-Host "pubspec_overrides.yaml retirado para evitar conflictos." -ForegroundColor Yellow
    }
}

Push-Location $Project
try {
    flutter clean
    if ($LASTEXITCODE -ne 0) {
        throw "flutter clean fallo."
    }

    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "flutter pub get fallo."
    }

    Write-Host ""
    Write-Host "Compilando APK release..." -ForegroundColor Cyan
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) {
        throw "La compilacion release fallo."
    }

    $Apk = Join-Path $Project "build\app\outputs\flutter-apk\app-release.apk"
    if (-not (Test-Path $Apk)) {
        throw "No se encontro el APK generado."
    }

    $apkItem = Get-Item $Apk
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " CORRECCION COMPLETADA" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "APK:    $($apkItem.FullName)"
    Write-Host "Tamano: $([Math]::Round($apkItem.Length / 1MB, 2)) MB"
    Write-Host ""
    Write-Host "Ahora ejecuta:"
    Write-Host "  flutter run --release"
} finally {
    Pop-Location
}
