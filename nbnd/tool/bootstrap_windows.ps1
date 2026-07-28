$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter no está disponible en PATH. Instálalo o abre una terminal donde flutter --version funcione."
}

$Backup = Join-Path $env:TEMP ("nbnd_source_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $Backup | Out-Null

$Items = @("lib", "assets", "test", "pubspec.yaml", "analysis_options.yaml", "README.md", "CHANGELOG.md", "CODEX_START_HERE.md")
foreach ($Item in $Items) {
  Copy-Item (Join-Path $ProjectRoot $Item) $Backup -Recurse -Force
}

flutter create . --platforms=android --org com.enmanuelapp --project-name nbnd

foreach ($Item in $Items) {
  $Target = Join-Path $ProjectRoot $Item
  if (Test-Path $Target) { Remove-Item $Target -Recurse -Force }
  Copy-Item (Join-Path $Backup $Item) $ProjectRoot -Recurse -Force
}

flutter pub get
Write-Host "NBND preparado. Ejecuta: flutter analyze; flutter test; flutter run" -ForegroundColor Green
