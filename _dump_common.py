#!/usr/bin/env python3
"""
Dump useful files from a Flutter project into the clipboard.

The script scans the project tree, keeps the files that usually matter for
context, and copies a Markdown-friendly dump to the clipboard. A text file is
written only as a fallback when the clipboard copy fails or the dump is too big.
"""

from __future__ import annotations

import os
import platform
import subprocess
import sys
from datetime import datetime
from pathlib import Path


EXTENSIONS = {".dart", ".yaml", ".yml", ".xml", ".gradle", ".kts", ".properties", ".json"}
EXACT_FILES = {"pubspec.lock"}

IGNORE_DIRS = {
    ".git",
    ".dart_tool",
    ".gradle",
    ".idea",
    ".vscode",
    "build",
    "ephemeral",
    "node_modules",
    "__pycache__",
    ".metadata",
}

IGNORE_FILES = {
    "local.properties",
    "key.properties",
    "keystore.properties",
    "google-services.json",
    "GoogleService-Info.plist",
}

FIXED_PATHS = {
    "pubspec.yaml",
    "pubspec.lock",
    "analysis_options.yaml",
    "android/build.gradle",
    "android/build.gradle.kts",
    "android/settings.gradle",
    "android/settings.gradle.kts",
    "android/gradle.properties",
    "android/app/build.gradle",
    "android/app/build.gradle.kts",
    "android/app/proguard-rules.pro",
    "android/app/src/main/AndroidManifest.xml",
    "ios/Podfile",
    "ios/Runner.xcodeproj/project.pbxproj",
    "web/index.html",
    "macos/Runner.xcodeproj/project.pbxproj",
}

MAX_CLIPBOARD_BYTES = 5 * 1024 * 1024


def language_for_extension(extension: str) -> str:
    return {
        ".dart": "dart",
        ".yaml": "yaml",
        ".yml": "yaml",
        ".xml": "xml",
        ".gradle": "groovy",
        ".kts": "kotlin",
        ".properties": "properties",
        ".json": "json",
    }.get(extension, "")


def should_include(relative_path: str, name: str, extension: str) -> bool:
    if name in IGNORE_FILES:
        return False
    if extension not in EXTENSIONS and name not in EXACT_FILES:
        return False

    normalized = relative_path.replace("\\", "/")
    if normalized.startswith("lib/") or normalized.startswith("test/"):
        return True
    if normalized.startswith("assets/content/"):
        return True
    if normalized in FIXED_PATHS:
        return True
    return False


def scan_files(base: Path) -> list[tuple[str, Path, str]]:
    found: list[tuple[str, Path, str]] = []

    for directory, folders, files in os.walk(base):
        folders[:] = [folder for folder in folders if folder not in IGNORE_DIRS]
        for name in files:
            absolute = Path(directory) / name
            relative = absolute.relative_to(base).as_posix()
            extension = absolute.suffix.lower()
            if should_include(relative, name, extension):
                found.append((relative, absolute, extension))

    found.sort(key=lambda item: item[0].lower())
    return found


def copy_to_clipboard(text: str) -> bool:
    try:
        system = platform.system().lower()
        if system == "windows":
            powershell = subprocess.run(
                [
                    "powershell",
                    "-NoProfile",
                    "-Command",
                    "Set-Clipboard -Value ([Console]::In.ReadToEnd())",
                ],
                input=text,
                text=True,
                encoding="utf-8",
                check=False,
            )
            if powershell.returncode == 0:
                return True

            clip = subprocess.run(["clip"], input=text.encode("utf-8"), check=False)
            return clip.returncode == 0
        if system == "darwin":
            process = subprocess.run(["pbcopy"], input=text.encode("utf-8"), check=False)
            return process.returncode == 0
        for cmd in (["xclip", "-selection", "clipboard"], ["xsel", "--clipboard"], ["wl-copy"]):
            try:
                process = subprocess.run(cmd, input=text.encode("utf-8"), check=False)
                if process.returncode == 0:
                    return True
            except FileNotFoundError:
                continue
    except Exception:
        return False
    return False


def build_dump(base: Path) -> str:
    files = scan_files(base)
    if not files:
        return ""

    lines = [
        "=== DUMP DE PROYECTO FLUTTER ===",
        f"Ruta: {base}",
        f"Fecha: {datetime.now():%Y-%m-%d %H:%M:%S}",
        f"Archivos: {len(files)}",
        "",
        "=== MAPA DE ARCHIVOS ===",
    ]

    lines.extend(relative for relative, _, _ in files)
    lines.append("")
    lines.append("=== CONTENIDOS ===")

    total = len(files)
    for index, (relative, absolute, extension) in enumerate(files, start=1):
        print(f"\rProcesando [{index}/{total}] {relative:<60}", end="", flush=True)
        try:
            content = absolute.read_text(encoding="utf-8", errors="replace")
        except Exception as error:
            content = f"<<ERROR AL LEER: {error}>>"

        lines.extend(
            [
                "",
                f"===== BEGIN FILE: {relative} =====",
                f"```{language_for_extension(extension)}",
                content.rstrip(),
                "```",
                f"===== END FILE: {relative} =====",
            ]
        )

    print("\r" + " " * 80 + "\r", end="")
    return "\n".join(lines)


def main(default_project: str | None = None) -> int:
    project_arg = sys.argv[1] if len(sys.argv) > 1 else default_project
    if not project_arg:
        project_arg = os.getcwd()

    base = Path(project_arg).expanduser().resolve()
    if not base.is_dir():
        print(f"Ruta no encontrada:\n{base}")
        return 1

    print(f"Escaneando: {base} ...")
    dump = build_dump(base)
    if not dump:
        print("No se encontraron archivos para dump.")
        return 0

    size_bytes = len(dump.encode("utf-8"))
    copied = False
    if size_bytes <= MAX_CLIPBOARD_BYTES:
        copied = copy_to_clipboard(dump)

    print("Proceso terminado.")
    print(f"Tamano: {size_bytes / 1024:.1f} KB")
    if copied:
        print("Copiado al portapapeles.")
    else:
        output_name = f"{base.name}_dump_{datetime.now():%Y%m%d_%H%M%S}.txt"
        output_path = Path.cwd() / output_name
        output_path.write_text(dump, encoding="utf-8")

        if size_bytes > MAX_CLIPBOARD_BYTES:
            print("Demasiado grande para el portapapeles (> 5 MB).")
        else:
            print("No se pudo copiar al portapapeles.")
        print(f"Guardado como respaldo en: {output_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
