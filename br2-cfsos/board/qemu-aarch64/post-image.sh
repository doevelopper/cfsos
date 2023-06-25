#!/bin/bash

set -eu

BOARD_DIR="$(cd "$(dirname "$0")"; pwd)"
START_QEMU_SCRIPT="${BINARIES_DIR}/start-qemu.sh"

cp -f "${BOARD_DIR}/grub.cfg" "${BINARIES_DIR}/efi-part/EFI/BOOT/grub.cfg"

declare -ar QEMU_CMD_LINE=(
"qemu-system-aarch64"
"-nographic"
"-M" "virt"
"-cpu" "cortex-a53"
"-smp" "1"
"-bios" "QEMU_EFI.fd"
"-netdev" "user,id=eth0"
"-device" "virtio-net-device,netdev=eth0"
"-drive" "file=disk.img,if=none,format=raw,id=hd0"
"-device" "virtio-blk-device,drive=hd0"
"-device" "virtio-rng-pci"
)

cat <<-_EOF_ > "${START_QEMU_SCRIPT}"
	#!/bin/sh
	(
	set -eu
	BINARIES_DIR="\$(cd "\$(dirname "\$0")"; pwd)"
	cd "\${BINARIES_DIR}"
	export PATH="${HOST_DIR}/bin:\${PATH}"
	exec ${QEMU_CMD_LINE[@]}
	)
_EOF_

chmod +x "${START_QEMU_SCRIPT}"
