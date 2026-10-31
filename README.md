# Ouros on AUP-ZU3

Vivado sources for the standalone Ouros Haskell processor FPGA/UART demo on
the [Real Digital AUP-ZU3](https://www.realdigital.org/hardware/aup-zu3). 
The HDL and program-memory images in `uart/` are committed so **Chisel and
MicroHs are not required** to rebuild this particular FPGA image.

The design uses the Zynq UltraScale+ PS for initialization, clocks and the
physical UART, while the graph-reduction processor itself runs in the PL.

## Prerequisites

- **Vivado 2025.1** with the Zynq UltraScale+ device support and the AUP-ZU3
  board definition `realdigital.org:aup-zu3-8gb:part0:1.0`. The target device
  is `xczu3eg-sfvc784-2-e`. Block-design IP versions come from this release.
- **Vitis 2025.1** with the embedded platform/FSBL components, and `bootgen`
  for a bootable image (not needed just to build the bitstream).
- AUP-ZU3 hardware for running the result.

## Build

Clone the repo, and from its root:

```sh
vivado -mode batch -source scripts/create_project.tcl
vivado -mode batch -source scripts/build_bitstream.tcl
```

`create_project.tcl` recreates the PS, AXI SmartConnect, reset network,
Ouros core, UART controller, and original address assignments via
`scripts/block_design.tcl`. It generates `system_wrapper` and targets the
AUP-ZU3. The build script runs implementation and writes:

- `build/boot/ouros.bit`
- `build/boot/ouros.xsa` (hardware platform including the bitstream)

The Vivado GUI project can be opened at `build/ouros-zu3/ouros-zu3.xpr`.
For a fresh rebuild, delete `build/` before running `create_project.tcl`
again. The scripts use their own location, not the current directory.

## Create BOOT.BIN

The existing Vitis platform creation script is retained with paths updated
to read `build/boot/ouros.xsa` and write under `build/vitis_ws`:

```sh
vitis -s boot/build_fsbl.py
```

Find the **FSBL ELF produced by your Vitis build** in `build/vitis_ws`.
Then package it with the bitstream using the original `boot/ouros.bif`:

```sh
python3 boot/package_boot.py --fsbl /path/to/zynqmp_fsbl.elf
```

This writes `build/boot/BOOT.BIN`. Place it on the board's booting SD card. 

## Repository contents

- `uart/`: pre-generated Verilog/SystemVerilog plus **`heap.mem` and
  `comb.mem`**, both used by `$readmemh` in the hardware memories.
- `constraints/`: BTN0 start and LED0 done pin constraints.
- `scripts/create_project.tcl`: portable project creation entry point.
- `scripts/block_design.tcl`: exported PS, AXI, UART, and Ouros block design;
  **do not source a second BD export into the same project**.
- `scripts/build_bitstream.tcl`: implementation and hardware export.
- `boot/`: existing BIF, Vitis build script, and image packaging helper.
- `build/`: generated files (ignored by Git).

## Notes

- The **AUP-ZU3 board files are not included**. [Download](https://www.realdigital.org/hardware/aup-zu3) and install it to your Vivado first.
- `uart/*.sv`, the two module-reference `.v` wrappers, and both `.mem`
  files must remain together. Updating the Ouros program requires replacing
  the images and rebuilding the bitstream.

- Related projects: 

  - Ouros Chisel hardware: https://github.com/bathtub-01/ouros-chisel/tree/real-world

  - Ouros simulator: https://github.com/bathtub-01/ouros-simulator/tree/real-world

  - MicroHs compiler fork: https://github.com/bathtub-01/MicroHs/tree/real-world
