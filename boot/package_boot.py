#!/usr/bin/env python3
"""Package an FSBL and the Vivado-produced bitstream using boot/ouros.bif."""
import argparse
from pathlib import Path
import shutil
import subprocess

root = Path(__file__).resolve().parent.parent
output = root / 'build' / 'boot'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--fsbl', type=Path, required=True,
                    help='path to the zynqmp_fsbl.elf produced by Vitis')
args = parser.parse_args()
fsbl = args.fsbl.expanduser().resolve()
bit = output / 'ouros.bit'
for path in (fsbl, bit, root / 'boot' / 'ouros.bif'):
    if not path.is_file():
        parser.error(f'missing input: {path}')
if shutil.which('bootgen') is None:
    parser.error('bootgen is not in PATH (source the AMD tool settings)')
output.mkdir(parents=True, exist_ok=True)
shutil.copy2(fsbl, output / 'zynqmp_fsbl.elf')
shutil.copy2(root / 'boot' / 'ouros.bif', output / 'ouros.bif')
subprocess.run(['bootgen', '-arch', 'zynqmp', '-image', 'ouros.bif',
                '-o', 'BOOT.BIN', '-w'], cwd=output, check=True)
print(f'Wrote {output / "BOOT.BIN"}')
