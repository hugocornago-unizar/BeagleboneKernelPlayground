#!/usr/bin/env bash
set -e

BOARD="${1^^}"

JOBS=$(nproc)


case $BOARD in 
	"BB" | "BEAGLEBONE" | "BONE")
		TARGET="ti/omap/am335x-bone.dtb"
		;;
	"BBB" | "BLACK" | "BEAGLEBONE BLACK" | "BEAGLEBONEBLACK" | "BONEBLACK")
		TARGET="ti/omap/am335x-boneblack.dtb"
		;;
	"")
		echo "usage: makekernel <board>"
		echo "boards supported:"
		echo -e "\t- BB"
		echo -e "\t- BBB"
		exit 1
		;;
	*)
		echo "unknown board: $BOARD"
		echo "boards supported:"
		echo -e "\t- BB"
		echo -e "\t- BBB"
		exit 2
		;;
esac

[[ -f Makefile ]] || {
	[[ -d kernel ]] || {
		echo "run \"nix develop\" first and make a config for the kernel"
		exit 3
	}

	cd kernel
	[[ -f Makefile ]] || {
		echo "couldn't find Makefile inside kernel/"
		exit 4
	}
}

[[ -f .config ]] || {
	make -j$JOBS omap2plus_defconfig
}

make -j$JOBS zImage
make -j$JOBS $TARGET
make -j$JOBS modules

mkdir -p rootfs
make -j$JOBS INSTALL_MOD_PATH=$PWD/rootfs modules_install
