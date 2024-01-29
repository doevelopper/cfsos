#!/bin/sh
set -e -x
NEW_ROOT=$1
TMP_DIR=$(mktemp -d)
mount /dev/mmcblk0p1 "${TMP_DIR}"
sed -e "s,root=/dev/mmcblk0p[0-9],${NEW_ROOT},g" -i "${TMP_DIR}/cmdline.txt"
umount "${TMP_DIR}"
