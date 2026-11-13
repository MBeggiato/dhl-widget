#!/usr/bin/env python3
"""Validate and reproducibly package the plasmoid using only Python stdlib."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parents[1]


def build(tag=None, output=None):
    package = ROOT / 'package'
    metadata = json.loads((package / 'metadata.json').read_text())
    plugin = metadata['KPlugin']
    version = plugin['Version']
    if not re.fullmatch(r'\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?', version):
        raise ValueError('KPlugin.Version must be a semantic version')
    if tag is not None and tag != f'v{version}':
        raise ValueError(f'Tag {tag!r} does not match metadata version v{version}')
    if plugin['Id'] != 'de.local.packstation':
        raise ValueError('Unexpected plugin ID; changing it breaks existing installations')
    if metadata.get('KPackageStructure') != 'Plasma/Applet':
        raise ValueError('Not a Plasma/Applet package')
    for required in ['contents/ui/main.qml', 'contents/config/main.xml', plugin['Icon']]:
        if not (package / required).is_file():
            raise ValueError(f'Missing required package file: {required}')
    ET.parse(package / 'contents/config/main.xml')
    ET.parse(package / plugin['Icon'])
    files = {'metadata.json': package / 'metadata.json', 'LICENSE': ROOT / 'LICENSE'}
    for path in (package / 'contents').rglob('*'):
        if path.is_symlink():
            raise ValueError(f'Symlinks are not allowed: {path}')
        if path.is_file():
            if path.suffix not in {'.qml', '.js', '.xml', '.svg'}:
                raise ValueError(f'Unexpected package asset: {path}')
            files[path.relative_to(package).as_posix()] = path
    output = Path(output) if output else ROOT / 'dist' / 'packstation.plasmoid'
    output.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(output, 'w', compression=ZIP_DEFLATED, compresslevel=9) as archive:
        for name, path in sorted(files.items()):
            entry = ZipInfo(name, date_time=(2020, 1, 1, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            entry.create_system = 3
            entry.external_attr = 0o100644 << 16
            archive.writestr(entry, path.read_bytes(), compresslevel=9)
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    checksum = output.with_name(output.name + '.sha256')
    checksum.write_text(f'{digest}  {output.name}\n')
    print(f'Built {output} (v{version}, {len(files)} files)')
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tag', help='Require an exact vVERSION match for release builds')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    build(args.tag, args.output)
