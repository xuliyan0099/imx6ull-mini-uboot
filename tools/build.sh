#!/usr/bin/env bash
# 编译 U-Boot，产物 out/u-boot-dtb.imx（可 dd 到 SD 卡偏移 0x400）。
#   bash tools/build.sh
# 环境变量：IM6_SRC / IM6_CROSS / IM6_JOBS
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=${IM6_SRC:-$ROOT/src}
CROSS=${IM6_CROSS:-arm-linux-gnueabihf-}
JOBS=${IM6_JOBS:-$(nproc)}
OUT=$ROOT/out
DEF=mx6ull_alientek_mini_defconfig

command -v "${CROSS}gcc" >/dev/null || { echo "缺少 ${CROSS}gcc" >&2; exit 1; }
[ -f "$SRC/u-boot/Makefile" ] || bash "$ROOT/tools/fetch.sh"

cp "$ROOT/board/$DEF" "$SRC/u-boot/configs/$DEF"
mkdir -p "$OUT"

make -C "$SRC/u-boot" "$DEF" >/dev/null
make -C "$SRC/u-boot" CROSS_COMPILE="$CROSS" -j"$JOBS"
cp "$SRC/u-boot/u-boot-dtb.imx" "$OUT/u-boot-dtb.imx"

echo
ls -l "$OUT/u-boot-dtb.imx"
sha256sum "$OUT/u-boot-dtb.imx"
