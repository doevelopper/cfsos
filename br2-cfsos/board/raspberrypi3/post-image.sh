#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-${BOARD_NAME}.cfg"
GENIMAGE_CFG="${BR2_EXTERNAL_CFSOS_PATH}/board/raspberrypi3/genimage-raspberrypi3-64.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?


# ITS_FILE="${BR2_EXTERNAL_CFSOS_PATH}/board/rpi3/rpi3_fit.its"
# CONFIG_FILE="${BR2_EXTERNAL_CFSOS_PATH}/board/rpi3/config.txt"

# cd ${BINARIES_DIR}
# echo $(pwd)

# mkdir -p boot
# cp image.fit boot/
# cp u-boot.bin boot/
# cp uboot-env.bin boot/
# cp armstub8.bin boot/
# #cp rpi-firmware/COPYING.linux boot/
# #cp rpi-firmware/LICENCE.broadcom boot/
# #cp rpi-firmware/bootcode.bin boot/
# #cp rpi-firmware/fixup.dat boot/
# #cp rpi-firmware/fixup_cd.dat boot/
# #cp rpi-firmware/fixup_db.dat boot/
# #cp rpi-firmware/fixup_x.dat boot/
# #cp rpi-firmware/start.elf boot/
# #cp rpi-firmware/start_cd.elf boot/
# #cp rpi-firmware/start_db.elf boot/
# #cp rpi-firmware/start_x.elf boot/
# cp ${CONFIG_FILE} boot/

# cd boot
# tar -cvf ../bootfs.tar .

# GENIMAGE_CFG="${BR2_EXTERNAL_CFSOS_PATH}/board/rpi3/genimage-raspberrypi3-64.cfg"
# GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# rm -rf "${GENIMAGE_TMP}"

# genimage                           \
# 	--rootpath "${TARGET_DIR}"     \
# 	--tmppath "${GENIMAGE_TMP}"    \
# 	--inputpath "${BINARIES_DIR}"  \
# 	--outputpath "${BINARIES_DIR}" \
# 	--config "${GENIMAGE_CFG}"

# exit $?
