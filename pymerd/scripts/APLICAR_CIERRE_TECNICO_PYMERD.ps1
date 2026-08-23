param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Text
    )
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )
    Write-Host ""
    Write-Host ">>> $Name" -ForegroundColor Cyan
    & $Action
    if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
        throw "$Name termino con codigo $LASTEXITCODE."
    }
}

$ProjectPath = [System.IO.Path]::GetFullPath($ProjectPath)
$Pubspec = Join-Path $ProjectPath "pubspec.yaml"
$PubspecLock = Join-Path $ProjectPath "pubspec.lock"
$AppGradle = Join-Path $ProjectPath "android\app\build.gradle.kts"
$Manifest = Join-Path $ProjectPath "android\app\src\main\AndroidManifest.xml"
$MainDart = Join-Path $ProjectPath "lib\main.dart"
$AdsConfig = Join-Path $ProjectPath "lib\ads\ads_config.dart"
$BannerDart = Join-Path $ProjectPath "lib\widgets\pyme_ad_banner.dart"
$Overrides = Join-Path $ProjectPath "pubspec_overrides.yaml"
$ThirdParty = Join-Path $ProjectPath "third_party"
$LocalPlugin = Join-Path $ThirdParty "google_mobile_ads_5_3_1_agp9"

foreach ($required in @($Pubspec, $AppGradle, $Manifest, $MainDart, $AdsConfig, $BannerDart)) {
    if (-not (Test-Path $required)) {
        throw "Falta un archivo requerido: $required"
    }
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Backup = Join-Path $ProjectPath "_backups\cierre_tecnico_admob_$timestamp"
New-Item -ItemType Directory -Path $Backup -Force | Out-Null

$logDir = Join-Path ([Environment]::GetFolderPath("Desktop")) "PYMERD_LOGS"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$Log = Join-Path $logDir "PYMERD_cierre_tecnico_$timestamp.log"

Start-Transcript -Path $Log -Force | Out-Null

try {
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host " PYMERD 0.1.0 - CIERRE TECNICO ADMOB + AGP 9 + API 21" -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host "Proyecto: $ProjectPath"
    Write-Host "Backup:   $Backup"
    Write-Host "Log:      $Log"

    # Copias de seguridad de archivos que este proceso puede tocar.
    foreach ($file in @($Pubspec, $PubspecLock, $AppGradle, $Overrides)) {
        if (Test-Path $file) {
            Copy-Item $file (Join-Path $Backup ([System.IO.Path]::GetFileName($file))) -Force
        }
    }
    if (Test-Path $LocalPlugin) {
        Copy-Item $LocalPlugin (Join-Path $Backup "google_mobile_ads_5_3_1_agp9_anterior") -Recurse -Force
    }

    # 1. Normalizar versión y dependencia.
    $pubspecText = Get-Content $Pubspec -Raw

    if ($pubspecText -match "(?m)^version:\s*.*$") {
        $pubspecText = [regex]::Replace(
            $pubspecText,
            "(?m)^version:\s*.*$",
            "version: 0.1.0+1"
        )
    } else {
        throw "pubspec.yaml no contiene una linea version."
    }

    if ($pubspecText -match "(?m)^\s*google_mobile_ads\s*:") {
        $pubspecText = [regex]::Replace(
            $pubspecText,
            "(?m)^\s*google_mobile_ads\s*:\s*.*$",
            "  google_mobile_ads: 5.3.1"
        )
    } else {
        $anchor = "(?m)^dependencies:\s*$"
        if ($pubspecText -notmatch $anchor) {
            throw "No se encontro la seccion dependencies en pubspec.yaml."
        }
        $pubspecText = [regex]::Replace(
            $pubspecText,
            $anchor,
            "dependencies:`r`n  google_mobile_ads: 5.3.1",
            1
        )
    }
    Write-Utf8NoBom -Path $Pubspec -Text $pubspecText

    # 2. Fijar API 21 explícitamente.
    $gradleText = Get-Content $AppGradle -Raw
    if ($gradleText -match "(?m)^\s*minSdk\s*=\s*flutter\.minSdkVersion\s*$") {
        $gradleText = [regex]::Replace(
            $gradleText,
            "(?m)^\s*minSdk\s*=\s*flutter\.minSdkVersion\s*$",
            "        minSdk = 21"
        )
    } elseif ($gradleText -match "(?m)^\s*minSdk\s*=\s*\d+\s*$") {
        $gradleText = [regex]::Replace(
            $gradleText,
            "(?m)^\s*minSdk\s*=\s*\d+\s*$",
            "        minSdk = 21"
        )
    } else {
        throw "No se encontro la configuracion minSdk en android/app/build.gradle.kts."
    }
    Write-Utf8NoBom -Path $AppGradle -Text $gradleText

    # 3. Confirmar que la integración de AdMob ya presente no fue perdida.
    $manifestText = Get-Content $Manifest -Raw
    if ($manifestText -notmatch [regex]::Escape("ca-app-pub-3322493998376707~6779988736")) {
        throw "AndroidManifest.xml no contiene el App ID de PYMERD."
    }

    $mainText = Get-Content $MainDart -Raw
    if ($mainText -notmatch "MobileAds\.instance\.initialize\(\)") {
        throw "lib/main.dart no inicializa MobileAds."
    }

    $adsText = Get-Content $AdsConfig -Raw
    if ($adsText -notmatch [regex]::Escape("ca-app-pub-3322493998376707/1982957622")) {
        throw "ads_config.dart no contiene el banner real de PYMERD."
    }
    if ($adsText -notmatch [regex]::Escape("ca-app-pub-3940256099942544/6300978111")) {
        throw "ads_config.dart no contiene el banner oficial de prueba."
    }

    # 4. Encontrar el paquete original ya descargado por Flutter.
    $cacheCandidates = New-Object System.Collections.Generic.List[string]

    if ($env:PUB_CACHE) {
        $cacheCandidates.Add((Join-Path $env:PUB_CACHE "hosted\pub.dev\google_mobile_ads-5.3.1"))
    }
    if ($env:LOCALAPPDATA) {
        $cacheCandidates.Add((Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev\google_mobile_ads-5.3.1"))
    }
    if ($env:USERPROFILE) {
        $cacheCandidates.Add((Join-Path $env:USERPROFILE "AppData\Local\Pub\Cache\hosted\pub.dev\google_mobile_ads-5.3.1"))
    }

    $SourcePlugin = $cacheCandidates |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1

    if (-not $SourcePlugin) {
        Push-Location $ProjectPath
        try {
            Invoke-Step "Descargando dependencias iniciales" { flutter pub get }
        } finally {
            Pop-Location
        }

        $SourcePlugin = $cacheCandidates |
            Where-Object { Test-Path $_ } |
            Select-Object -First 1
    }

    if (-not $SourcePlugin) {
        throw "No se encontro google_mobile_ads-5.3.1 en el cache de Pub."
    }

    Write-Host "Plugin original: $SourcePlugin" -ForegroundColor Green

    # 5. Crear copia local y aplicar la corrección exacta para Gradle 9.
    New-Item -ItemType Directory -Path $ThirdParty -Force | Out-Null
    if (Test-Path $LocalPlugin) {
        Remove-Item $LocalPlugin -Recurse -Force
    }
    Copy-Item $SourcePlugin $LocalPlugin -Recurse -Force

    $PluginGradle = Join-Path $LocalPlugin "android\build.gradle"
    if (-not (Test-Path $PluginGradle)) {
        throw "La copia local no contiene android/build.gradle."
    }

    $pluginText = Get-Content $PluginGradle -Raw
    $pattern = "for\s*\(\s*def\s+configuration\s*:\s*configurations\.all\s*\)\s*\{"
    if ($pluginText -match $pattern) {
        $pluginText = [regex]::Replace(
            $pluginText,
            $pattern,
            "for (def configuration : configurations) {",
            1
        )
        Write-Utf8NoBom -Path $PluginGradle -Text $pluginText
    } elseif ($pluginText -notmatch "for\s*\(\s*def\s+configuration\s*:\s*configurations\s*\)\s*\{") {
        throw "El build.gradle del plugin no contiene la linea conocida ni su version corregida."
    }

    $verifyPlugin = Get-Content $PluginGradle -Raw
    if ($verifyPlugin -match $pattern) {
        throw "La expresion incompatible configurations.all sigue presente."
    }

    # 6. Hacer que solo PYMERD use la copia local.
    if (Test-Path $Overrides) {
        $existingOverride = Get-Content $Overrides -Raw
        if ($existingOverride -notmatch "google_mobile_ads_5_3_1_agp9") {
            throw "Ya existe pubspec_overrides.yaml con otra configuracion. Se conservo en el backup y no se mezclo automaticamente."
        }
    }

    $overrideText = @"
dependency_overrides:
  google_mobile_ads:
    path: third_party/google_mobile_ads_5_3_1_agp9
"@
    Write-Utf8NoBom -Path $Overrides -Text $overrideText

    Push-Location $ProjectPath
    try {
        Invoke-Step "Limpiando compilaciones anteriores" { flutter clean }
        Invoke-Step "Resolviendo dependencias con plugin local" { flutter pub get }

        $lockText = Get-Content $PubspecLock -Raw
        $lockPattern = "(?s)google_mobile_ads:\s+dependency:.*?source:\s+path\s+version:\s+""5\.3\.1"""
        if ($lockText -notmatch $lockPattern) {
            Write-Host "Contenido relacionado en pubspec.lock:" -ForegroundColor Yellow
            Select-String -Path $PubspecLock -Pattern "google_mobile_ads:" -Context 0,10
            throw "pubspec.lock no confirma google_mobile_ads 5.3.1 como dependencia local."
        }

        Invoke-Step "Formateando codigo Dart" { dart format lib test }
        Invoke-Step "Analizando proyecto" { flutter analyze --no-fatal-warnings --no-fatal-infos }
        Invoke-Step "Ejecutando pruebas" { flutter test }
        Invoke-Step "Compilando APK release" { flutter build apk --release }

        $Apk = Join-Path $ProjectPath "build\app\outputs\flutter-apk\app-release.apk"
        if (-not (Test-Path $Apk)) {
            throw "Flutter termino, pero no se encontro el APK esperado."
        }

        $apkInfo = Get-Item $Apk
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host " CIERRE TECNICO COMPLETADO" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host "APK:     $($apkInfo.FullName)"
        Write-Host "Tamano:  $([Math]::Round($apkInfo.Length / 1MB, 2)) MB"
        Write-Host "Version: 0.1.0+1"
        Write-Host "minSdk:  21"
        Write-Host "Anuncios de prueba por defecto."
        Write-Host ""
        Write-Host "Para ejecutarla en el telefono:"
        Write-Host "  flutter run --release"
    } finally {
        Pop-Location
    }

    Stop-Transcript | Out-Null
    exit 0
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Se guardo respaldo en: $Backup" -ForegroundColor Yellow
    Write-Host "Registro: $Log" -ForegroundColor Yellow
    try { Stop-Transcript | Out-Null } catch {}
    exit 1
}
