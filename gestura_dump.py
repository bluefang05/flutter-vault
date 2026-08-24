from pathlib import Path
from _dump_common import main


if __name__ == "__main__":
    base_dir = Path(__file__).resolve().parent
    target_path = base_dir / "gestura" if (base_dir / "gestura").exists() else base_dir / "conove"
    raise SystemExit(main(str(target_path)))
