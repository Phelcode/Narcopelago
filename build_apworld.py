#!/usr/bin/env python3
"""Builds schedule_I.apworld from worlds/Schedule_I.

A .apworld is a zip of the world folder. The Archipelago launcher validates it before
installing (worlds/LauncherComponents.py in ArchipelagoMW/Archipelago): the zip root must
contain exactly one directory, that directory's name must appear in the file name
(case-sensitive), entry paths must use forward slashes, and schedule_I/__init__.py must
exist. Hence the output is named schedule_I.apworld and the root folder inside the zip is
schedule_I (first letter lowercased from Schedule_I).

With --check, only validates the existing schedule_I.apworld instead of rebuilding.
Keep in sync with build-apworld.ps1 (same rules, PowerShell version for local Windows use).
"""
import argparse
import os
import pathlib
import sys
import zipfile

REPO_ROOT = pathlib.Path(__file__).resolve().parent
WORLD_DIR = REPO_ROOT / "worlds" / "Schedule_I"
OUT = REPO_ROOT / "schedule_I.apworld"
ROOT_NAME = WORLD_DIR.name[0].lower() + WORLD_DIR.name[1:]
SKIP_DIRS = {"__pycache__"}
SKIP_EXTS = {".pyc", ".pyd", ".so", ".dll"}


def build() -> None:
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(WORLD_DIR):
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
            for f in files:
                if os.path.splitext(f)[1].lower() in SKIP_EXTS:
                    continue
                full = os.path.join(root, f)
                arc = ROOT_NAME + "/" + os.path.relpath(full, WORLD_DIR).replace(os.sep, "/")
                z.write(full, arc)
    print(f"built {OUT} ({OUT.stat().st_size} bytes)")


def check(path: pathlib.Path) -> bool:
    """Mirror of the launcher's validation in worlds/LauncherComponents.py."""
    try:
        with zipfile.ZipFile(path) as z:
            directories = [f.name for f in zipfile.Path(z).iterdir() if f.is_dir()]
            stem = path.stem
            if not (len(directories) == 1 and directories[0] in stem):
                print(f"FAIL: root dirs {directories}, file stem {stem!r}")
                return False
            z.open(directories[0] + "/__init__.py")
    except (zipfile.BadZipFile, KeyError) as e:
        print(f"FAIL: {e}")
        return False
    print(f"OK: {path.name} stem={stem!r} root dir={directories[0]!r}")
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="only validate the existing schedule_I.apworld")
    args = parser.parse_args()
    if not args.check:
        build()
    sys.exit(0 if check(OUT) else 1)
