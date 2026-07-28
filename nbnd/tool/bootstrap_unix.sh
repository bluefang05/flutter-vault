#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter no está disponible en PATH." >&2
  exit 1
fi

BACKUP="$(mktemp -d)"
trap 'rm -rf "$BACKUP"' EXIT

for item in lib assets test pubspec.yaml analysis_options.yaml README.md CHANGELOG.md CODEX_START_HERE.md; do
  cp -R "$item" "$BACKUP/"
done

flutter create . --platforms=android --org com.enmanuelapp --project-name nbnd

for item in lib assets test pubspec.yaml analysis_options.yaml README.md CHANGELOG.md CODEX_START_HERE.md; do
  rm -rf "$item"
  cp -R "$BACKUP/$item" .
done

flutter pub get
echo "NBND preparado. Ejecuta: flutter analyze && flutter test && flutter run"
