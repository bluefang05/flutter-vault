$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Project = "C:\Users\manue\OneDrive\Desktop\proyectos\flutter\pymerd"
$Pubspec = Join-Path $Project "pubspec.yaml"
$Lock = Join-Path $Project "pubspec.lock"
$AppGradle = Join-Path $Project "android\app\build.gradle.kts"
$AdsGradle = Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev\google_mobile_ads-5.3.1\android\build.gradle"

if (-not (Test-Path $Pubspec)) { throw "No se encontro PYMERD en $Project" }
if (-not (Test-Path $AppGradle)) { throw "No se encontro android\app\build.gradle.kts" }

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Backup = Join-Path $Project "_backups\cierre_api21_$timestamp"
New-Item -ItemType Directory -Path $Backup -Force | Out-Null

foreach ($file in @($Pubspec, $Lock, $AppGradle)) {
    if (Test-Path $file) {
        Copy-Item $file (Join-Path $Backup ([IO.Path]::GetFileName($file))) -Force
    }
}
if (Test-Path $AdsGradle) {
    Copy-Item $AdsGradle (Join-Path $Backup "google_mobile_ads_build.gradle") -Force
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " PYMERD - CIERRE ANDROID API 21" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Backup: $Backup"
Write-Host ""

# minSdk 21 explicito.
$gradleText = Get-Content $AppGradle -Raw
if ($gradleText -match "(?m)^\s*minSdk\s*=\s*flutter\.minSdkVersion\s*$") {
    $gradleText = [regex]::Replace(
        $gradleText,
        "(?m)^\s*minSdk\s*=\s*flutter\.minSdkVersion\s*$",
        "        minSdk = 21",
        1
    )
} elseif ($gradleText -match "(?m)^\s*minSdk\s*=\s*\d+\s*$") {
    $gradleText = [regex]::Replace(
        $gradleText,
        "(?m)^\s*minSdk\s*=\s*\d+\s*$",
        "        minSdk = 21",
        1
    )
} else {
    throw "No se encontro la linea minSdk."
}
[IO.File]::WriteAllText($AppGradle, $gradleText, (New-Object Text.UTF8Encoding($false)))

# dependency_overrides para WebView.
$pubspecText = Get-Content $Pubspec -Raw
$pubspecText = [regex]::Replace(
    $pubspecText,
    "(?m)^[ ]{2}webview_flutter_android\s*:\s*[^\r\n]+\r?\n?",
    ""
)

if ($pubspecText -match "(?m)^dependency_overrides:\s*$") {
    $pubspecText = [regex]::Replace(
        $pubspecText,
        "(?m)^dependency_overrides:\s*$",
        "dependency_overrides:`r`n  webview_flutter_android: 4.10.1",
        1
    )
} elseif ($pubspecText -match "(?m)^dev_dependencies:\s*$") {
    $pubspecText = [regex]::Replace(
        $pubspecText,
        "(?m)^dev_dependencies:\s*$",
        "dependency_overrides:`r`n  webview_flutter_android: 4.10.1`r`n`r`ndev_dependencies:",
        1
    )
} else {
    throw "No se encontro dev_dependencies."
}

[IO.File]::WriteAllText($Pubspec, $pubspecText, (New-Object Text.UTF8Encoding($false)))

Push-Location $Project
try {
    $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"

    & ".\android\gradlew.bat" --stop
    $global:LASTEXITCODE = 0

    flutter clean
    if ($LASTEXITCODE -ne 0) { throw "flutter clean fallo." }

    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get fallo." }

    # Reaplicar parche AdMob después de pub get.
    if (-not (Test-Path $AdsGradle)) {
        throw "No se encontro google_mobile_ads 5.3.1."
    }

    $adsText = Get-Content $AdsGradle -Raw
    $oldAds = "for (def configuration : configurations.all) {"
    $newAds = "for (def configuration : configurations) {"

    if ($adsText.Contains($oldAds)) {
        $adsText = $adsText.Replace($oldAds, $newAds)
        [IO.File]::WriteAllText($AdsGradle, $adsText, (New-Object Text.UTF8Encoding($false)))
        Write-Host "Parche AdMob reaplicado." -ForegroundColor Green
    } elseif ($adsText.Contains($newAds)) {
        Write-Host "Parche AdMob ya estaba correcto." -ForegroundColor Green
    } else {
        throw "No se encontro la linea esperada en google_mobile_ads 5.3.1."
    }

    if (-not (Test-Path $Lock)) { throw "No se genero pubspec.lock." }
    $lockText = Get-Content $Lock -Raw
    if ($lockText -notmatch '(?s)webview_flutter_android:.*?version:\s+"4\.10\.1"') {
        Select-String -Path $Lock -Pattern "webview_flutter_android:" -Context 0,10
        throw "pubspec.lock no confirma webview_flutter_android 4.10.1."
    }

    Write-Host ""
    Write-Host "WebView Android 4.10.1 confirmado." -ForegroundColor Green

    flutter build apk --release
    if ($LASTEXITCODE -ne 0) { throw "La compilacion release fallo." }

    $Apk = Join-Path $Project "build\app\outputs\flutter-apk\app-release.apk"
    if (-not (Test-Path $Apk)) { throw "No se encontro app-release.apk." }

    $item = Get-Item $Apk
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " PYMERD API 21 COMPLETADO" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "APK:    $($item.FullName)"
    Write-Host "Tamano: $([Math]::Round($item.Length / 1MB, 2)) MB"
    Write-Host "minSdk: 21"
    Write-Host "WebView Android: 4.10.1"
    Write-Host "AdMob: 5.3.1 parcheado"
} finally {
    Pop-Location
}
