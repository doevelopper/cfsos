#!/bin/bash

function os_image_name() {
  echo "${BINARIES_DIR}/${OS_ID}-${BOARD_ID}-$(os_version).${1}"
}

function os_version() {
  if [ -z "${VERSION_POSTFIX}" ]; then
    echo "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}"
  else
    echo "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_POSTFIX}"
  fi
}

function rauc_compatible() {
    echo "${BOARD_ID}"
}

p3-gen-random-ports() {
    export MY_NW_PORT=$((50000 + RANDOM % 15000)) # port: 50000-65000
    export MY_SW_PORT=$(expr ${MY_NW_PORT} + 1)
    echo "set ports: normal world: ${MY_NW_PORT}  sec world :${MY_SW_PORT}"
}

# will gen deterministic ports instead
p3-gen-hash-ports() {
    export MY_NW_PORT=`echo -n ${USER} | md5sum | cut -c1-8 | printf "%d\n" 0x$(cat -) | awk '{printf "%.0f\n", 50000 + (($1 / 0xffffffff) * 10000)}'`
    export MY_SW_PORT=$(expr ${MY_NW_PORT} + 1)
    echo "set ports: normal world: ${MY_NW_PORT}  sec world :${MY_SW_PORT}"
}


p3-console-normal() {
    nc -l 127.0.0.1 ${MY_NW_PORT}
    # also ... 
    # while true; do nc -l 127.0.0.1 ${MY_NW_PORT}; done        
}

p3-console-sec() {
    nc -l 127.0.0.1 ${MY_SW_PORT}
    # also ...
    # while true; do nc -l 127.0.0.1 ${MY_SW_PORT}; done        
}
