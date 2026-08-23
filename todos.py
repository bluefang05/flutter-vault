from __future__ import annotations

from pathlib import Path

from _dump_common import main


PROJECTS = [
    ("adapa kr", "adapa_kr"),
    ("biblia 73", "Biblia Catolica 73"),
    ("brote cero", "brote_cero"),
    ("casileo", "casileo"),
    ("conove", "conove"),
    ("deapoco", "deapoco"),
    ("grapa", "grapa"),
    ("haciendo", "Haciendo"),
    ("hocicos", "hocicos"),
    ("inhala", "inhala"),
    ("mesenti", "mesenti"),
    ("nbnd", "nbnd"),
    ("pymerd", "pymerd"),
    ("sefeliz", "sefeliz"),
    ("siyase", "siyase"),
    ("soysomos", "soysomos"),
    ("teleo", "teleo"),
    ("voxel anaconda", "voxel_anaconda"),
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
