#!/usr/bin/env python3
"""Install individual configs with journalled backups; Python 3.9+."""
import argparse
import json
import os
from pathlib import Path
import shlex
import shutil
import tempfile

ROOT = Path(__file__).resolve().parent


def exists(path):
    return os.path.lexists(path)


def save(path, data):
    temp = path.with_suffix('.pending')
    temp.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    os.replace(temp, path)


def restore(receipt):
    receipt = receipt.resolve()
    data = json.loads(receipt.read_text())
    if data['status'] == 'restored':
        print('Already restored:', receipt)
        return
    for other in receipt.parent.parent.glob('*/receipt.json'):
        newer = json.loads(other.read_text())
        if newer.get('previous') == str(receipt) and newer['status'] != 'restored':
            raise RuntimeError('Restore the newer installation first: ' + str(other))
    for item in reversed(data['files']):
        target = Path(item['target'])
        original = receipt.parent / item['backup']
        displaced = receipt.parent / ('after-' + item['backup'])
        if item.get('restored'):
            continue
        if exists(original) or (not item['existed'] and item.get('applied')):
            if exists(target):
                if exists(displaced):
                    raise RuntimeError('Recovery file already exists: ' + str(displaced))
                shutil.move(str(target), str(displaced))
            if exists(original):
                shutil.move(str(original), str(target))
        item['restored'] = True
        save(receipt, data)
    data['status'] = 'restored'
    save(receipt, data)
    print('Restored. Displaced files retained in:', receipt.parent)


def install(home, config):
    if not home.is_absolute() or not config.is_absolute():
        raise ValueError('Target home and config directory must be absolute paths')
    if any(c in str(home) + str(config) for c in '\n\r'):
        raise ValueError('Newlines in paths are unsupported')
    plans = []

    def add(target, text, mode=0o644):
        plans.append((target, text, mode))

    aero = (ROOT / 'config/aerospace.toml').read_text()
    start = config / 'omarchy-macos/start.sh'
    aero = 'after-startup-command = [' + json.dumps('exec-and-forget /bin/bash ' + shlex.quote(str(start))) + ']\n' + aero
    add(home / '.aerospace.toml', aero)
    for alt in sorted({config / 'aerospace/aerospace.toml', home / '.config/aerospace/aerospace.toml'}):
        if exists(alt):
            plans.append((alt, None, 0o644))
    for source in sorted((ROOT / 'config/sketchybar').rglob('*')):
        if source.is_file():
            add(config / 'sketchybar' / source.relative_to(ROOT / 'config/sketchybar'), source.read_text(), 0o755)
    add(config / 'starship.toml', (ROOT / 'config/starship.toml').read_text())
    add(config / 'fish/conf.d/omarchy-macos.fish', (ROOT / 'config/fish/conf.d/omarchy-macos.fish').read_text())
    add(config / 'borders/bordersrc', (ROOT / 'config/borders/bordersrc').read_text(), 0o755)
    add(start, (ROOT / 'config/start.sh').read_text(), 0o755)
    native = home / 'Library/Application Support/com.mitchellh.ghostty'
    add(native / 'config', (ROOT / 'config/ghostty/config').read_text())
    add(native / 'config.ghostty', '# Managed settings are in the adjacent config file.\n')
    changed = []
    for target, text, mode in plans:
        if target.is_dir() and not target.is_symlink():
            raise RuntimeError('Expected a file, found directory: ' + str(target))
        if text is not None and target.is_file() and not target.is_symlink():
            if target.read_text() == text and target.stat().st_mode & 0o777 == mode:
                continue
        changed.append((target, text, mode))
    if not changed:
        print('Configs already match; no changes or new backup.')
        return
    backup_root = config / 'omarchy-macos-backups'
    backup_root.mkdir(parents=True, exist_ok=True)
    receipts = sorted(backup_root.glob('*/receipt.json'), key=lambda p: p.stat().st_mtime_ns)
    previous = next((str(p.resolve()) for p in reversed(receipts) if json.loads(p.read_text())['status'] != 'restored'), None)
    backup = Path(tempfile.mkdtemp(prefix='install-', dir=backup_root))
    receipt = backup / 'receipt.json'
    data = {'status': 'installing', 'previous': previous, 'files': []}
    save(receipt, data)
    try:
        for index, (target, text, mode) in enumerate(changed):
            target.parent.mkdir(parents=True, exist_ok=True)
            item = {'target': str(target), 'backup': str(index), 'existed': exists(target), 'applied': False}
            data['files'].append(item)
            save(receipt, data)
            if item['existed']:
                shutil.move(str(target), str(backup / item['backup']))
            item['applied'] = True
            save(receipt, data)
            if text is not None:
                target.write_text(text)
                target.chmod(mode)
        data['status'] = 'installed'
        save(receipt, data)
    except Exception:
        restore(receipt)
        raise
    print('Config files installed. Applications have not been started.')
    print('Restore: bash ' + shlex.quote(str(ROOT / 'install.sh')) + ' --restore ' + shlex.quote(str(receipt)))
    print('Start panel: bash ' + shlex.quote(str(start)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target-home', type=Path, default=Path.home())
    parser.add_argument('--config-home', type=Path)
    parser.add_argument('--restore', type=Path, help='receipt.json from the installation to undo')
    args = parser.parse_args()
    if args.restore:
        restore(args.restore)
    else:
        config = args.config_home or Path(os.environ.get('XDG_CONFIG_HOME', str(args.target_home / '.config')))
        install(args.target_home, config)


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        raise SystemExit('ERROR: ' + str(error))
