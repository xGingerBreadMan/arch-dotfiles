#!/usr/bin/env python3
"""Preview a dotfiles restore, or apply with a backup of existing destinations."""
import argparse
from datetime import datetime, timezone
from pathlib import Path
import os
import shutil


def restore(source, target, apply=False):
    backup = target / '.local/state/dotfiles-backups' / datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    count = 0
    for src in sorted(source.rglob('*')):
        if src.is_dir() and not src.is_symlink():
            continue
        rel = src.relative_to(source)
        dst = target / rel
        # Do not follow pre-existing directory symlinks into unexpected locations.
        for parent in dst.parents:
            if parent == target:
                break
            if parent.is_symlink():
                raise RuntimeError(f'Refusing destination beneath symlink: {parent}')
        print(('Restore ' if apply else 'Would restore ') + str(dst))
        if apply:
            if dst.exists() or dst.is_symlink():
                saved = backup / rel
                saved.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(dst), str(saved))
            dst.parent.mkdir(parents=True, exist_ok=True)
            if src.is_symlink():
                dst.symlink_to(os.readlink(src))
            else:
                shutil.copy2(src, dst)
        count += 1
    print(f'{count} files. ' + (f'Existing files backed up under {backup}' if apply else 'Preview only; use --apply to restore.'))
    return backup


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    restore(Path(__file__).resolve().parent / 'home', Path.home(), args.apply)
