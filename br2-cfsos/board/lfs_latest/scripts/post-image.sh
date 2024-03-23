#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-${BOARD_NAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
BR2_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

MKIMAGE=$HOST_DIR/usr/bin/mkimage
BOOT_CMD=$BOARD_DIR/../boot.scr
BOOT_CMD_H=$BINARIES_DIR/boot.scr.uimg
UPDATE_CMD=$BOARD_DIR/../update.scr
UPDATE_CMD_H=$BINARIES_DIR/update.scr.uimg

GCC_VERSION=$(${BR2_TOOLCHAIN_EXTERNAL_PREFIX}-gcc --version | head -1 | sed 's/.*(\(.*\))/\1/')
BIN_VERSION=$(${BR2_TOOLCHAIN_EXTERNAL_PREFIX}-as --version | head -1 | sed 's/.*(\(.*\))/\1/')
GCC_TRIPLE=$(${BR2_TOOLCHAIN_EXTERNAL_PREFIX}-gcc -v -c  2>&1 | sed 's/ /\n/g' | grep -e "--target" | awk -F= '{print $2}')

echo "${BR2_PRODUCT^^} POST BUILD script: starting..."
echo "-------------------------------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------------------------------"
echo "BOARD_DIR    = ${BOARD_DIR} ${BR2_TOOLCHAIN_EXTERNAL_PREFIX}"
echo "BR2_CONF     = ${BR2_CONFIG}"
echo "HOST_DIR     = ${HOST_DIR}"
echo "STAGING_DIR  = ${STAGING_DIR}"
echo "TARGET_DIR   = ${TARGET_DIR}"
echo "BUILD_DIR    = ${BUILD_DIR}"
echo "BINARIES_DIR = ${BINARIES_DIR}"
echo "BASE_DIR     = ${BASE_DIR}"
echo "GENIMAGE_CFG = ${GENIMAGE_CFG}"
echo "GENIMAGE_TMP = ${GENIMAGE_TMP}"
echo "GCC_VERSION  = ${GCC_VERSION}"
echo "BIN_VERSION  = ${BIN_VERSION}"
echo "GCC_TRIPLE   = ${GCC_TRIPLE}"
echo "-------------------------------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------------------------------"


# generate genimage from template if a board specific variant doesn't exists
if [ ! -e "${GENIMAGE_CFG}" ]; then
	echo "${GENIMAGE_CFG} not found"
	GENIMAGE_CFG="${BINARIES_DIR}/genimage.cfg"
	FILES=()
	echo "${GENIMAGE_CFG} Will contains ${BOARD_DIR} config"
	for i in "${BINARIES_DIR}"/*.dtb "${BINARIES_DIR}"/rpi-firmware/*; do
		FILES+=( "${i#${BINARIES_DIR}/}" )
	done
	
	yes | cp -v "${BOARD_DIR}/../config_3_64bit.txt" "${BINARIES_DIR}/rpi-firmware/config.txt"

	if ! grep -Fxq "enable_uart=1" ${BINARIES_DIR}/rpi-firmware/config.txt
	then
		echo "enable_uart=1" >> ${BINARIES_DIR}/rpi-firmware/config.txt
	fi

	KERNEL=$(sed -n 's/^kernel=//p' "${BINARIES_DIR}/rpi-firmware/config.txt")
	echo " Add ${KERNEL} OS as a item to copy... "
	FILES+=( "${KERNEL}" )

	if grep -Eq "^BR2_TARGET_UBOOT=y$" ${BR2_CONFIG}; then
		echo "Change config.txt to boot u-boot.bin instead of (z)Image"
		# KERNEL=$(sed -e '/^kernel=/s,=.*,=u-boot.bin,' -i "${BINARIES_DIR}/rpi-firmware/config.txt")
		sed -e '/^kernel=/s,=.*,=u-boot.bin,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		
		DAS_UBOOT=$(sed -n 's/^kernel=//p' "${BINARIES_DIR}/rpi-firmware/config.txt")
		echo " Add ${DAS_UBOOT} Bootloader as a item to copy... "
		FILES+=( "${DAS_UBOOT}" )
		echo " Add ${DAS_UBOOT} env as a item to copy... "
		FILES+=( "uboot-env.bin" )

		${HOST_DIR}/bin/mkimage -C none -A arm64 -T script -d $BOARD_DIR/boot.txt $BINARIES_DIR/boot.scr
		# mkimage -A arm64 -O linux -T script -d ./rpi3-bootscript.txt ./boot.scr
		FILES+=( "boot.scr" )
	fi

	BOOT_FILES=$(printf '\\t\\t\\t"%s",\\n' "${FILES[@]}")
	

	if grep -Eq "^BR2_TARGET_ROOTFS_EXT2=y$" ${BR2_CONFIG}; then
		echo " EX4 ${GENIMAGE_CFG} "
		sed "s|#BOOT_FILES#|${BOOT_FILES}|" "${BOARD_DIR}/genimage.cfg.in" > "${GENIMAGE_CFG}"
	fi

	if grep -Eq "^BR2_TARGET_ROOTFS_SQUASHFS=y$" ${BR2_CONFIG}; then
		echo " SquashFS ${GENIMAGE_CFG} "
		sed "s|#BOOT_FILES#|${BOOT_FILES}|" "${BOARD_DIR}/genimage-squashfs.cfg.in" > "${GENIMAGE_CFG}"
	fi	
fi


# $ubootName/tools/mkimage -C none -A arm -T script -d $BR2_EXTERNAL_RK3308_PATH/board/RK3308/boot.cmd $BINARIES_DIR/boot.scr

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
