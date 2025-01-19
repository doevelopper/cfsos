#!/bin/bash
# shellcheck disable=SC1091

set -u
set -e

KEY_PATH="${BR2_EXTERNAL_CFSOS_PATH}/board/common/rootfs-overlay/etc/ssh"
TARGET_KEY_PATH="${TARGET_DIR}/etc/ssh/"
if [ ! -f "${KEY_PATH}/ssh_host_rsa_key" ]; then
	ssh-keygen -t rsa -b 2048 -f "${KEY_PATH}/ssh_host_rsa_key" -N ""
	cp ${KEY_PATH}/ssh_host_rsa_key ${TARGET_KEY_PATH}
fi
if [ ! -f "${KEY_PATH}/ssh_host_dsa_key" ]; then
	ssh-keygen -t dsa -b 1024 -f "${KEY_PATH}/ssh_host_dsa_key" -N ""
	cp ${KEY_PATH}/ssh_host_dsa_key ${TARGET_KEY_PATH}
fi
if [ ! -f "${KEY_PATH}/ssh_host_ecdsa_key" ]; then
	ssh-keygen -t ecdsa -b 256 -f "${KEY_PATH}/ssh_host_ecdsa_key" -N ""
	cp ${KEY_PATH}/ssh_host_ecdsa_key ${TARGET_KEY_PATH}
fi
if [ ! -f "${KEY_PATH}/ssh_host_ed25519_key" ]; then
	ssh-keygen -t ed25519 -b 2048 -f "${KEY_PATH}/ssh_host_ed25519_key" -N ""
	cp ${KEY_PATH}/ssh_host_ed25519_key ${TARGET_KEY_PATH}
fi

# RSA Key
# if [ ! -f "${KEY_PATH}/ssh_host_rsa_key" ]; then
#     $(HOST_DIR)/bin/openssl genrsa -out "${KEY_PATH}/ssh_host_rsa_key" 2048
#     cp ${KEY_PATH}/ssh_host_rsa_key ${TARGET_KEY_PATH}
# fi

# # DSA Key (Note: The standard size for DSA keys is 1024 bits, but be aware modern systems discourage DSA keys)
# if [ ! -f "${KEY_PATH}/ssh_host_dsa_key" ]; then
#     $(HOST_DIR)/bin/openssl dsaparam -out "${KEY_PATH}/ssh_host_dsa_key.pem" 1024
#     $(HOST_DIR)/bin/openssl dsa -in "${KEY_PATH}/ssh_host_dsa_key.pem" -outform pem -out "${KEY_PATH}/ssh_host_dsa_key"
#     cp ${KEY_PATH}/ssh_host_dsa_key ${TARGET_KEY_PATH}
# fi

# # ECDSA Key
# if [ ! -f "${KEY_PATH}/ssh_host_ecdsa_key" ]; then
#     $(HOST_DIR)/bin/openssl ecparam -name prime256v1 -genkey -out "${KEY_PATH}/ssh_host_ecdsa_key"
#     cp ${KEY_PATH}/ssh_host_ecdsa_key ${TARGET_KEY_PATH}
# fi

# # Ed25519 Key (Note: OpenSSL command might vary based on version)
# if [ ! -f "${KEY_PATH}/ssh_host_ed25519_key" ]; then
#     $(HOST_DIR)/bin/openssl genpkey -algorithm ed25519 -out "${KEY_PATH}/ssh_host_ed25519_key"
#     cp ${KEY_PATH}/ssh_host_ed25519_key ${TARGET_KEY_PATH}
# fi

SCRIPT_DIR=${BR2_EXTERNAL_CFSOS_PATH}/board/common

BOARD_DIR=${2}
. "${BR2_EXTERNAL_CFSOS_PATH}/meta"
. "${BR2_EXTERNAL_CFSOS_PATH}/board/neuron/rpi3-64/meta"
. "${SCRIPT_DIR}/post-helpers.sh"

# Write os-release
(
    echo "NAME=\"${OS_NAME}\""
    echo "VERSION=\"$(os_version) (${BOARD_NAME})\""
    echo "ID=${OS_ID}"
    echo "VERSION_ID=$(os_version)"
    echo "PRETTY_NAME=\"${OS_NAME} $(os_version)\""
    echo "HOME_URL=\"https://github.com/superbox-dev\""
) > "${TARGET_DIR}/usr/lib/os-release"

# Write issue
echo "${OS_NAME} $(os_version)" > "${TARGET_DIR}/etc/issue"

# Update motd
cat > "${TARGET_DIR}/etc/motd" <<EOL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Hello, this is ${OS_NAME} $(os_version)
Documentation: https://github.com/superbox-dev/unipi-control#readme

EOL

# Create mount point directories
mkdir -pv "${TARGET_DIR}/mnt/boot"
mkdir -pv "${TARGET_DIR}/mnt/overlay"

function setup_zsh() {
  sed -i '/^root:/s,:/bin/dash$,:/bin/zsh,' "${TARGET_DIR}/etc/passwd"
}

function setup_rauc() {
  sed -i "/compatible/s/=.*\$/=$(rauc_compatible)/" "${TARGET_DIR}/etc/rauc/system.conf"
}

function fix_rootfs() {
  # Cleanup etc
  rm -rfv "${TARGET_DIR:?}/etc/init.d"
  rm -rfv "${TARGET_DIR:?}/etc/X11"
  rm -rfv "${TARGET_DIR:?}/etc/xdg"

  # Cleanup root
  rm -rfv "${TARGET_DIR:?}/srv"

  sed -i "/srv/d" "${TARGET_DIR}/usr/lib/tmpfiles.d/home.conf"

  mkdir -pv "${TARGET_DIR}/boot/"
  # cp -fv "${BINARIES_DIR}/Image" "${TARGET_DIR}/boot/"

  mkdir -pv "${TARGET_DIR}/opt/unipi/"
  mkdir -pv "${TARGET_DIR}/usr/local/"
  mkdir -pv "${TARGET_DIR}/var/rauc/"
}


setup_zsh
setup_rauc
fix_rootfs

"${HOST_DIR}/bin/systemctl" --root="${TARGET_DIR}" preset-all
