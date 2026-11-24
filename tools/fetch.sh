#!/usr/bin/env bash
# 拉 U-Boot v2026.10 到 src/u-boot，并打上 i.MX6ULL Mini 板级补丁。
#   bash tools/fetch.sh
# 环境变量：IM6_SRC / IM6_UB_URL / IM6_FORCE=1
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=${IM6_SRC:-$ROOT/src}
UB_TAG=v2026.10
UB_URL=${IM6_UB_URL:-https://github.com/u-boot/u-boot.git}
: "${IM6_FORCE:=0}"
PATCH=$ROOT/board/0001-mx6ull-alientek-mini-port.patch

mkdir -p "$SRC"

if [ ! -d "$SRC/u-boot/.git" ] || [ "$IM6_FORCE" = 1 ]; then
  echo "== 克隆 U-Boot $UB_TAG =="
  rm -rf "$SRC/u-boot"
  git clone --depth 1 --branch "$UB_TAG" "$UB_URL" "$SRC/u-boot"
else
  echo "== 复用已有 U-Boot 源码 =="
  git -C "$SRC/u-boot" describe --tags 2>/dev/null || true
fi

cd "$SRC/u-boot"
if git apply --check "$PATCH" 2>/dev/null; then
  git apply "$PATCH"
  echo "   板级补丁已应用"
elif git apply --reverse --check "$PATCH" 2>/dev/null; then
  echo "   板级补丁已应用过（跳过）"
else
  echo "!! 补丁既打不上也退不掉，源码树可能被改过，删掉 $SRC/u-boot 重跑" >&2
  exit 1
fi

echo "源码就绪：$SRC/u-boot"
