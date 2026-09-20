import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import subprocess
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('manager', Path(__file__).resolve().parents[1] / 'manage.py')
manager = importlib.util.module_from_spec(spec)
spec.loader.exec_module(manager)


class InstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='omarchy-test-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.home = self.base / 'User Home'
        self.config = self.base / 'Custom Config'
        self.home.mkdir()
        self.config.mkdir()

    def put(self, path, text):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def install(self):
        with contextlib.redirect_stdout(io.StringIO()):
            manager.install(self.home, self.config)

    def receipts(self):
        return sorted((self.config / 'omarchy-macos-backups').glob('*/receipt.json'), key=lambda p: p.stat().st_mtime_ns)

    def restore(self, receipt):
        with contextlib.redirect_stdout(io.StringIO()):
            manager.restore(receipt)

    def test_roundtrip_existing_configs_and_unrelated_plugins(self):
        native = self.home / 'Library/Application Support/com.mitchellh.ghostty'
        originals = {
            self.home / '.aerospace.toml': 'original aero',
            self.config / 'aerospace/aerospace.toml': 'alternate aero',
            native / 'config': 'theme = old',
            native / 'config.ghostty': 'config-file = other',
            self.config / 'fish/config.fish': 'user shell config',
            self.config / 'sketchybar/plugins/custom.sh': 'user plugin',
        }
        for path, text in originals.items():
            self.put(path, text)
        self.install()
        self.assertFalse((self.config / 'aerospace/aerospace.toml').exists())
        self.assertIn('Catppuccin', (native / 'config').read_text())
        self.assertEqual((self.config / 'sketchybar/plugins/custom.sh').read_text(), 'user plugin')
        self.restore(self.receipts()[0])
        for path, text in originals.items():
            self.assertEqual(path.read_text(), text)
        self.assertFalse((self.config / 'starship.toml').exists())

    def test_reinstall_is_idempotent(self):
        self.install()
        self.install()
        self.assertEqual(len(self.receipts()), 1)

    def test_symlink_is_restored_without_modifying_referent(self):
        original = self.base / 'dotfiles/aero.toml'
        self.put(original, 'dotfiles original')
        target = self.home / '.aerospace.toml'
        target.symlink_to(original)
        self.install()
        self.assertFalse(target.is_symlink())
        self.assertEqual(original.read_text(), 'dotfiles original')
        self.restore(self.receipts()[0])
        self.assertTrue(target.is_symlink())
        self.assertEqual(target.resolve(), original.resolve())

    def test_reverse_order_and_retention_of_later_edits(self):
        self.install()
        first = self.receipts()[0]
        target = self.config / 'starship.toml'
        target.write_text('user edit')
        self.install()
        second = self.receipts()[-1]
        with self.assertRaisesRegex(RuntimeError, 'newer'):
            self.restore(first)
        self.restore(second)
        self.assertEqual(target.read_text(), 'user edit')
        self.restore(first)
        self.assertFalse(target.exists())
        self.assertTrue(any(p.read_text() == 'user edit' for p in first.parent.glob('after-*') if p.is_file()))
        self.restore(first)

    def test_install_failure_automatically_restores_original(self):
        target = self.home / '.aerospace.toml'
        self.put(target, 'original')
        actual_write = Path.write_text

        def failing_write(path, text, *args, **kwargs):
            if path.name == 'sketchybarrc':
                raise OSError('simulated disk failure')
            return actual_write(path, text, *args, **kwargs)

        with patch.object(Path, 'write_text', failing_write):
            with self.assertRaisesRegex(OSError, 'simulated'):
                self.install()
        self.assertEqual(target.read_text(), 'original')
        self.assertEqual(json.loads(self.receipts()[0].read_text())['status'], 'restored')

    def test_activation_surfaces_reload_failure(self):
        fakebin = self.base / 'bin'
        self.put(fakebin / 'aerospace', '#!/bin/sh\necho rejected-config >&2\nexit 42\n')
        self.put(fakebin / 'pgrep', '#!/bin/sh\nexit 0\n')
        for executable in fakebin.iterdir():
            executable.chmod(0o755)
        # Use a copy of the activation script without its Homebrew PATH prefix,
        # so no real application can shadow the isolated command doubles.
        script = (manager.ROOT / 'activate.sh').read_text().replace(
            'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"', '')
        result = subprocess.run(['/bin/bash', '-c', script], env={**os.environ, 'PATH': str(fakebin) + ':/usr/bin:/bin'}, capture_output=True, text=True)
        self.assertEqual(result.returncode, 42)
        self.assertIn('rejected-config', result.stderr)


if __name__ == '__main__':
    unittest.main()
