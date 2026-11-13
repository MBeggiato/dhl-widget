"""Tests for release archives; no third-party dependencies."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('builder', ROOT / 'scripts/build.py')
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)


class BuildTests(unittest.TestCase):
    def test_reproducible_and_clean_archive(self):
        with tempfile.TemporaryDirectory() as directory:
            first = builder.build(output=Path(directory) / 'first.plasmoid')
            second = builder.build(output=Path(directory) / 'second.plasmoid')
            self.assertEqual(first.read_bytes(), second.read_bytes())
            with ZipFile(first) as archive:
                names = archive.namelist()
                self.assertIn('LICENSE', names)
                self.assertIn('contents/ui/main.qml', names)
                self.assertIn('contents/images/packstation.svg', names)
                self.assertFalse(any(name.startswith(('tests/', 'dist/', '.github/')) for name in names))
                self.assertTrue(all(info.date_time == (2020, 1, 1, 0, 0, 0) for info in archive.infolist()))
                self.assertEqual(archive.testzip(), None)
            self.assertTrue(first.with_name(first.name + '.sha256').is_file())

    def test_tag_matches_metadata(self):
        version = json.loads((ROOT / 'package/metadata.json').read_text())['KPlugin']['Version']
        with tempfile.TemporaryDirectory() as directory:
            builder.build(tag=f'v{version}', output=Path(directory) / 'release.plasmoid')
        with self.assertRaises(ValueError):
            builder.build(tag='v999.999.999')


if __name__ == '__main__':
    unittest.main()
