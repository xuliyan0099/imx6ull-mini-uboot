# imx6ull-mini-uboot

正点原子 **i.MX6ULL Mini**（Cortex-A7 / 512 MiB DDR / eMMC + SD）的 U-Boot **v2026.10** 移植。

上游源码不进库：`tools/fetch.sh` 按 tag 浅克隆后打一枚小补丁，`tools/build.sh` 编出
`out/u-boot-dtb.imx`（400,384 B）。

## 快速开始

```bash
sudo apt install build-essential bison flex bc libssl-dev gcc-arm-linux-gnueabihf
git clone https://github.com/xuliyan0099/imx6ull-mini-uboot.git
cd imx6ull-mini-uboot
bash tools/build.sh          # 首次会自动 fetch
```

产物：`out/u-boot-dtb.imx`，烧到 SD/eMMC 偏移 `0x400`（IVT 位置）：

```bash
sudo dd if=out/u-boot-dtb.imx of=/dev/sdX bs=512 seek=2 conv=fsync
```

## 板级改动（都在 `board/`）

`0001-mx6ull-alientek-mini-port.patch` 相对上游只有三处加两个新文件：

| 文件 | 改动 |
| --- | --- |
| `configs/mx6ull_alientek_mini_defconfig` | 新增：`CONFIG_TARGET_MX6ULL_14X14_EVK`、`TEXT_BASE=0x87800000`、`DEFAULT_DEVICE_TREE="imx6ull-alientek-mini"`、`ENV_IS_IN_MMC` + `ENV_OFFSET=0xC0000`、`BOOTDELAY=1`、`PHY_MICREL_KSZ8XXX`，双路 BOOTCOMMAND（`mmc 0:1` / `mmc 1:1` 各 `ext4load ... /boot/zImage`） |
| `arch/arm/dts/imx6ull-alientek-mini.dts` | 新增：ATK-4.3 RGBLCD 800×480、GT911 触摸、SD/eMMC、FEC、USB OTG |
| `arch/arm/mach-imx/mx6/soc.c` | 改：① ANA bandgap 上电死等改成有界重试（QEMU 不实现该模拟量）；② `#if 0` 掉 `is_mx6ul()` 分支里的 SNVS GPBIT / PMIC_STBY_REQ pad 配置（QEMU 的 IOMUX 表没有这些 pad，会 assert） |

这两处 `soc.c` 改动只影响 QEMU 兼容性，真板上行为与上游一致。

## 验证

- 串口：`U-Boot 2026.10`、`Model: Alientek i.MX6ULL Mini`、`DRAM: 512 MiB`、`FSL_SDHC: 0, 1`，进 `=>`。
- 真板：`mmc dev 0; fatload mmc 0:1 0x80800000 zImage` 可正常加载并 `bootz`。
- 产物大小与旧固件一致（400,384 B），说明补丁没有引入额外段。

## 环境变量

| 变量 | 默认 | 用途 |
| --- | --- | --- |
| `IM6_SRC` | `./src` | 上游源码目录 |
| `IM6_UB_URL` | GitHub 官方仓库 | 内网镜像 |
| `IM6_CROSS` | `arm-linux-gnueabihf-` | 交叉前缀 |
| `IM6_JOBS` | `nproc` | 并行度 |
| `IM6_FORCE=1` | 0 | 强制重拉源码 |

许可：板级补丁与配置 MIT；U-Boot 本体 GPL-2.0+。
