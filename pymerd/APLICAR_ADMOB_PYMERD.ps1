$ErrorActionPreference = 'Stop'

Write-Host '============================================================'
Write-Host ' PYME RD - INTEGRACION ADMOB SEGURA (API 21)'
Write-Host '============================================================'

if (-not (Test-Path 'pubspec.yaml')) {
    throw 'Ejecuta este script desde la carpeta raiz del proyecto pymerd.'
}
if (-not (Test-Path 'lib\screens\home_shell.dart')) {
    throw 'No se encontro lib\screens\home_shell.dart.'
}

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backup = Join-Path '_backups' "antes_admob_$stamp"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

$files = @(
    'pubspec.yaml',
    'lib\main.dart',
    'lib\screens\home_shell.dart',
    'android\app\src\main\AndroidManifest.xml',
    'android\app\build.gradle.kts'
)
foreach ($file in $files) {
    if (Test-Path $file) {
        $target = Join-Path $backup $file
        New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
        Copy-Item $file $target -Force
    }
}

Write-Host "Copia de seguridad: $backup"

New-Item -ItemType Directory -Path 'lib\ads' -Force | Out-Null
New-Item -ItemType Directory -Path 'lib\widgets' -Force | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'lib\ads\ads_config.dart') 'lib\ads\ads_config.dart' -Force
Copy-Item (Join-Path $PSScriptRoot 'lib\widgets\pyme_ad_banner.dart') 'lib\widgets\pyme_ad_banner.dart' -Force

$utf8 = New-Object System.Text.UTF8Encoding($false)

# 1. Dependencia fijada en la ultima rama que conserva Android API 21.
$pubspecPath = 'pubspec.yaml'
$pubspec = [IO.File]::ReadAllText($pubspecPath)
if ($pubspec -notmatch '(?m)^\s{2}google_mobile_ads\s*:') {
    if ($pubspec -match '(?m)^\s{2}pdf\s*:[^\r\n]+') {
        $pubspec = [regex]::Replace(
            $pubspec,
            '(?m)^(\s{2}pdf\s*:[^\r\n]+)$',
            "`$1`r`n  google_mobile_ads: 5.3.1",
            1
        )
    } else {
        $pubspec = [regex]::Replace(
            $pubspec,
            '(?m)^(dependencies\s*:\s*)$',
            "`$1`r`n  google_mobile_ads: 5.3.1",
            1
        )
    }
} else {
    $pubspec = [regex]::Replace(
        $pubspec,
        '(?m)^\s{2}google_mobile_ads\s*:[^\r\n]+$',
        '  google_mobile_ads: 5.3.1'
    )
}
[IO.File]::WriteAllText($pubspecPath, $pubspec, $utf8)

# 2. Inicializar Mobile Ads al arrancar.
$mainPath = 'lib\main.dart'
$main = [IO.File]::ReadAllText($mainPath)
if ($main -notmatch "import 'dart:async';") {
    $main = "import 'dart:async';`r`n`r`n" + $main
}
if ($main -notmatch "package:google_mobile_ads/google_mobile_ads.dart") {
    $main = $main.Replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';`r`nimport 'package:google_mobile_ads/google_mobile_ads.dart';"
    )
}
if ($main -notmatch 'MobileAds\.instance\.initialize') {
    $main = $main.Replace(
        'WidgetsFlutterBinding.ensureInitialized();',
        "WidgetsFlutterBinding.ensureInitialized();`r`n  unawaited(MobileAds.instance.initialize());"
    )
}
[IO.File]::WriteAllText($mainPath, $main, $utf8)

# 3. Sustituir la franja ficticia por el banner real/test.
$homePath = 'lib\screens\home_shell.dart'
$home = [IO.File]::ReadAllText($homePath)
if ($home -notmatch "widgets/pyme_ad_banner.dart") {
    $home = $home.Replace(
        "import '../widgets/common.dart';",
        "import '../widgets/common.dart';`r`nimport '../widgets/pyme_ad_banner.dart';"
    )
}
if ($home -match 'const\s+AdStrip\s*\(\s*\)') {
    $home = [regex]::Replace(
        $home,
        'const\s+AdStrip\s*\(\s*\)',
        'PymeAdBanner(visible: _index == 0 || _index == 2 || _index == 3)',
        1
    )
} elseif ($home -notmatch 'PymeAdBanner\s*\(') {
    throw 'No se encontro la franja AdStrip en home_shell.dart. Se restauraran los archivos.'
}
[IO.File]::WriteAllText($homePath, $home, $utf8)

# 4. App ID y permisos Android.
$manifestPath = 'android\app\src\main\AndroidManifest.xml'
$manifest = [IO.File]::ReadAllText($manifestPath)
if ($manifest -notmatch 'android.permission.ACCESS_NETWORK_STATE') {
    $manifest = $manifest.Replace(
        '<uses-permission android:name="android.permission.INTERNET" />',
        "<uses-permission android:name=`"android.permission.INTERNET`" />`r`n    <uses-permission android:name=`"android.permission.ACCESS_NETWORK_STATE`" />"
    )
}
if ($manifest -notmatch 'com.google.android.gms.ads.APPLICATION_ID') {
    $metadata = @'
        <!-- AdMob App ID de PYME RD. No confundir con el ID del banner. -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3322493998376707~6779988736" />

'@
    $manifest = $manifest.Replace('        <activity', $metadata + '        <activity')
} else {
    $manifest = [regex]::Replace(
        $manifest,
        '(?s)(android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID"\s*\r?\n\s*android:value=")[^"]+("\s*/>)',
        '${1}ca-app-pub-3322493998376707~6779988736${2}'
    )
}
[IO.File]::WriteAllText($manifestPath, $manifest, $utf8)

# 5. Mantener expresamente API 21.
$gradlePath = 'android\app\build.gradle.kts'
$gradle = [IO.File]::ReadAllText($gradlePath)
$gradle = $gradle.Replace('minSdk = flutter.minSdkVersion', 'minSdk = 21')
[IO.File]::WriteAllText($gradlePath, $gradle, $utf8)

Write-Host ''
Write-Host '[1/5] Limpiando...'
flutter clean
if ($LASTEXITCODE -ne 0) { throw 'flutter clean fallo.' }

Write-Host '[2/5] Instalando dependencias...'
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get fallo.' }

Write-Host '[3/5] Formateando...'
dart format lib\main.dart lib\ads\ads_config.dart lib\widgets\pyme_ad_banner.dart lib\screens\home_shell.dart
if ($LASTEXITCODE -ne 0) { throw 'dart format fallo.' }

Write-Host '[4/5] Analizando...'
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze encontro errores.' }

Write-Host '[5/5] Ejecutando pruebas...'
flutter test
if ($LASTEXITCODE -ne 0) { throw 'flutter test fallo.' }

Write-Host ''
Write-Host 'ADMOB INTEGRADO.' -ForegroundColor Green
Write-Host 'flutter run --release usa SIEMPRE el banner de prueba.'
Write-Host 'Para el AAB oficial ejecuta: .\COMPILAR_AAB_PYMERD.ps1'
