KERNEL_DEFCONFIG ?= rockchip_linux_defconfig

kernel:
	git clone https://github.com/ayufan-rock64/linux-mainline-kernel kernel

kernel/.config: kernel/arch/arm64/configs/$(KERNEL_DEFCONFIG)
	make -C kernel $(KERNEL_DEFCONFIG) ARCH=arm64

ifeq ($(FORCE), 1)
.PHONY: tftproot/kernel-arm64
endif
tftproot/kernel-arm64: kernel/.config
	make -C kernel Image ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j$$(nproc)
	cp kernel/arch/arm64/boot/Image $@

tftproot/dtbs/rockchip/rk3328-rock64.dtb: tftproot/kernel-arm64 \
	kernel/arch/arm64/boot/dts/rockchip/rk3328-rock64.dts \
	kernel/arch/arm64/boot/dts/rockchip/rk3328.dtsi
	make -C kernel dtbs ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j$$(nproc)
	make -C kernel dtbs_install ARCH=arm64 INSTALL_DTBS_PATH=$(CURDIR)/tftproot/dtbs

.PHONY: tftproot-kernel
tftproot-kernel: \
	tftproot/kernel-arm64 \
	tftproot/dtbs/rockchip/rk3328-rock64.dtb

.PHONY: kernel-menuconfig
kernel-menuconfig:
	make -C kernel ARCH=arm64 $(KERNEL_DEFCONFIG)
	make -C kernel ARCH=arm64 menuconfig
	make -C kernel ARCH=arm64 savedefconfig
	cp kernel/defconfig kernel/arch/arm64/configs/$(KERNEL_DEFCONFIG)
