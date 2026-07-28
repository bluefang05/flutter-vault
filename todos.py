from __future__ import annotations

from pathlib import Path

from dump_flutter import main


PROJECTS = [
    ("biblia 73", "Biblia Catolica 73"),
    ("deapoco", "deapoco"),
    ("hocicos", "hocicos"),
    ("inhala", "inhala"),
    ("mesenti", "mesenti"),
    ("nbnd", "nbnd"),
    ("sefeliz", "sefeliz"),
    ("siyase", "siyase"),
    ("soysomos", "soysomos"),
    ("teleo", "teleo"),
]


def run_all() -> int:
    base_dir = Path(__file__).resolve().parent
    exit_code = 0

    for label, folder in PROJECTS:
        project_path = base_dir / folder
        print(f"\n=== {label} ===")
        result = main(str(project_path))
        if result != 0:
            exit_code = result

    return exit_code


if __name__ == "__main__":
    raise SystemExit(run_all())
