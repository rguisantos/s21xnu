#!/bin/bash
# Stage-1 build: arm64 Image for `kexec -l` (no boot.img). Needs aarch64-linux-gnu-{gcc,binutils}.
set -euo pipefail
cd "$(dirname "$0")"
CC=${CC:-aarch64-linux-gnu-gcc}; OBJCOPY=${OBJCOPY:-aarch64-linux-gnu-objcopy}
# BOARD=t2s (default, S21+), p3s (S21 Ultra, full 1440x3200) or p3s-window
# (S21 Ultra, 1080x2400 window with the 1440-pixel stride): framebuffer geometry.
BOARD=${BOARD:-t2s}
case "$BOARD" in
  t2s) BOARD_CFLAGS= ;;
  p3s) BOARD_CFLAGS=-DSWEET_BOARD_P3S ;;
  p3s-window) BOARD_CFLAGS=-DSWEET_BOARD_P3S_WINDOW ;;
  *) echo "error: unknown BOARD=$BOARD (t2s|p3s|p3s-window)" >&2; exit 1 ;;
esac
CFLAGS="$BOARD_CFLAGS -O2 -ffreestanding -nostdlib -fno-pic -mgeneral-regs-only -mstrict-align -fno-stack-protector -Wall -Wextra"
mkdir -p out
for f in start.S shim.c console.c mmu.c fdt.c loader.c ufs.c; do $CC $CFLAGS -c $f -o out/${f%.*}.o; done
abs=$(aarch64-linux-gnu-readelf -r out/shim.o out/console.o out/mmu.o out/fdt.o out/loader.o out/ufs.o | grep -c ABS64 || true)
[ "$abs" = 0 ] || { echo "error: $abs absolute relocations in C objects" >&2; exit 1; }
$CC $CFLAGS -static -T shim.ld -Wl,--build-id=none -Wl,--no-warn-rwx-segments -Wl,-N \
  out/start.o out/shim.o out/console.o out/mmu.o out/fdt.o out/loader.o out/ufs.o -o out/shim.elf
$OBJCOPY -O binary out/shim.elf out/Image
size=$(printf '%d' 0x$(aarch64-linux-gnu-nm out/shim.elf | awk '$3=="_end"{print $1}'))
truncate -s "$size" out/Image
ls -l out/Image
