from __future__ import annotations

from pathlib import Path

from dump_flutter import main


PROJECTS = [
    "Biblia Catolica 73",
    "deapoco",
    "hocicos",
    "inhala",
    "mesenti",
    "sefeliz",
    "siyase",
    "soysomos",
    "teleo",
]


def run_all() -> int:
    base_dir = Path(__file__).resolve().parent
    exit_code = 0

    for project in PROJECTS:
        project_path = base_dir / project
        print(f"\n=== {project} ===")
        result = main(str(project_path))
        if result != 0:
            exit_code = result

    return exit_code


if __name__ == "__main__":
    raise SystemExit(run_all())
