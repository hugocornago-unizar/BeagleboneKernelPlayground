#!/usr/bin/env bash
set -e

DEVICE=$1

prompt_warning() {
	echo "This program will erase all the data inside $DEVICE"
	read -p "Continue? (y/n)" prompt
	case $prompt in
		[yY]* | [sS]*)
			;;
		*)
			echo "Aborting..."
			exit 2
			;;
	esac
}

[[ -z $1 ]] && {
	echo "usage: flashkernel <sd card device (/dev/sdX)>"
	echo "options:"
	echo -e "\t -f, --full: remove all contents from the device and install a bootloader and busybox."
	echo -e "\t -b, --build: build the kernel before flashing."
	echo -e "\t -q, --quiet: don't print any step."
	exit 1
}

# check partition of drive
echo -n "Checking device... "
format=`lsblk -o FSTYPE ${DEVICE}0 | tail -n1`
echo "OK"
echo $format
