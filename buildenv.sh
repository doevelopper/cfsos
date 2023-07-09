#!/usr/bin/env bash
# This script for first time use buildroot in whole new enviroment
# Test Pass Enviroemnt : Ubuntu 16.04/18.04/20.04, Arch Linux

VERBOSE=1
ARG_RUN_INSTALL_REQUIED=0
ARG_RUN_INSTALL_PYTHON=0
#PRINT_WARNING_FLAG=0
# ======================================================================================================================
# ANSI text coloring
BLUE='\033[94m'
CYAN='\033[0;36m'
DARKCYAN='\033[36m'
GREEN='\033[0;32m'
PURPLE='\033[95m'
RED='\033[0;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'

NOCOLOR='\033[0m'
UNDERLINE='\033[4m'
ITALIC="\e[3m"
BOLD='\033[1m'
END='\033[m'

# ======================================================================================================================
CLI_PACKAGES_REQUIED=(
    'which'
    'sed'
    'make'
    'addr2line' # binutils
    'gcc'
    'g++'
    'bash'
    'patch'
    'gzip'
    'bzip2'
    'perl'
    'tar'
    'cpio'
    'unzip'
    'rsync'
    'file'
    'bc'
    'wget'
    'git'
    'xzcat'
    'autoconf'
    'automake'
)
CLI_PACKAGES_PYTHON=(
    'pyenv'
    'python'
    'dot'
)
CLI_PACKAGES_OPTIONAL=(
    'scp'
    'svn'
    'bzr'
    'cvs'
    'hg'
    'lzip'
)
# support manual
# pakcage: ascii w3m dblatex
# ======================================================================================================================
# question fcuntion
confirm() {
    local _prompt _default _response

    _prompt="Are you sure?"
    if [ "$1" ]; then _prompt="$1"; fi

    _prompt2="$_prompt [y/n]"
    if [ "$2" ]; then _prompt2="$_prompt $2"; fi

    # Loop forever until the user enters a valid response (Y/N or Yes/No).
    while true; do
        read -r -p "  $_prompt2
  " _response
        case "$_response" in
        [Yy][Ee][Ss]|[Yy]) # Yes or Y (case-insensitive).
            REPLY="0"
            return $REPLY
            ;;
        [Nn][Oo]|[Nn])  # No or N.
            REPLY="1"
            return $REPLY
            ;;
        [Hh])  # H or h. H stands for Half.
            REPLY="2"
            return $REPLY
            ;;
        *) # Anything else (including a blank) is invalid.
            ;;
        esac
    done
}

# ======================================================================================================================
# Write out a command and run it
# vexec {minVerbosity} {command...}
vexec() {
    local LEVEL=$1; shift
    if [ $VERBOSE -ge 0 ]; then
        echo -n "[RUN]: "
        local CMD=( )
        for i in "${@}"; do
            # Replace argument's spaces with ''; if different, quote the string
            if [ "$i" != "${i/ /}" ]; then
                CMD=( ${CMD[@]} "'${i}'" )
            else
                CMD=( ${CMD[@]} $i )
            fi
        done
        echo "${CMD[@]}"
    fi
    ${@}
}

# ======================================================================================================================
# detect distro name
trim() {
    set -f
    # shellcheck disable=2048,2086
    set -- $*
    printf '%s\n' "${*//[[:space:]]/}"
    set +f
}
IFS=" " read -ra uname <<< "$(uname -srm)"

kernel_name="${uname[0]}"
case $kernel_name in
    Linux)
        os=Linux
    ;;

    *)
        echo ' $kernel_name not supported'>&2
        do_exit
    ;;
esac

case $os in
    Linux)
        if type -p lsb_release >/dev/null; then
            distro=$(lsb_release -si)

        elif [[ -f /etc/os-release || \
            -f /usr/lib/os-release || \
            -f /etc/openwrt_release || \
            -f /etc/lsb-release ]]; then

            # Source the os-release file
            for file in /etc/lsb-release /usr/lib/os-release \
                        /etc/os-release  /etc/openwrt_release; do
                source "$file" 2>/dev/null && break
            done
            distro="${PRETTY_NAME:-${DISTRIB_DESCRIPTION}} ${UBUNTU_CODENAME}"
        fi
        ;;
esac

# ======================================================================================================================
# detect default shell
DEFAULT_SHELL=$(grep ^$(id -un): /etc/passwd | cut -d : -f  7- | rev | cut -d/ -f 1 | rev)


# ======================================================================================================================
# exit function
do_exit() {
    echo ""
    echo "      cancel operation...."
    echo ""
    echo -e "${WHITE}  😭  Bye  ${END}"
    echo ""
    exit 1
}
trap do_exit SIGINT

# ======================================================================================================================
# MAIN program start
echo ""
echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
echo ""
echo -e "${WHITE}    Welcome Buildroot Installer Script ${END}"
echo ""
echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"

echo "     T___      "
echo "     |O O|     "
echo "     \_^_/     "
echo "    /|(\)|\     MAINTAINER: austinsuyoyo"
echo "   d |___| b   "
echo ""
echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
echo -e "${WHITE}    Check required command...${END}"
echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"


for cli in "${CLI_PACKAGES_REQUIED[@]}";
do
    hash $cli >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}  ❌  $cli not instlled ${END}"
        ARG_RUN_INSTALL_REQUIED=1
    else
        echo -e "${GREEN}  ✅  $cli is installed.${END}"
    fi
done
echo -e "      Buildroot command ${BOLD}\`make graph-build\`${END} & ${BOLD}\`make pkg-stats\`${END} need python enviroment."
confirm "❓  Do you want to setup python enviroment use pyenv ?" "(y/n)"
if [ "$REPLY" == "0" ]; then # 0 = Yes
    for cli in "${CLI_PACKAGES_PYTHON[@]}";
    do
        hash $cli >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}  ❌  $cli not instlled ${END}"
            ARG_RUN_INSTALL_PYTHON=1
        else
            echo -e "${GREEN}  ✅  $cli is installed.${END}"
        fi
    done
fi

echo -e "      Default shell is ${GREEN}${BOLD}$DEFAULT_SHELL${END}"
confirm "❓  Do you want to setup some sciprt on $DEFAULT_SHELL?" "(y/n)"
if [ "$REPLY" == "0" ]; then # 0 = Yes
    SETUP_SHELL=$DEFAULT_SHELL
fi

if [ $ARG_RUN_INSTALL_REQUIED = 1 ]; then
echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
echo -e "${WHITE}    Installed required package...${END}"
echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"

case $(trim "$distro") in
    "Arch"*)
        #update all package and index
        vexec $VERBOSE pacman -R --noconfirm fakeroot-tcp
        vexec $VERBOSE pacman -Syyu --noconfirm
        if [ $ARG_RUN_INSTALL_REQUIED = 1 ]; then
            vexec $VERBOSE pacman -S --needed --noconfirm base-devel unzip wget git bc cpio rsync
        fi
        ;;
    "Ubuntu"*)
        vexec $VERBOSE sudo apt-get -qq update
        if [ $ARG_RUN_INSTALL_REQUIED = 1 ]; then
            vexec $VERBOSE sudo apt-get install -qq \
                make \
                build-essential \
                unzip \
                libncurses-dev \
                autoconf \
                automake \
                libtool \
                git \
                xz-utils
        fi
        ;;
    *)
        echo -e "${RED}  ❌  not support $distro OS to install package ${END}"
        do_exit
        ;;
esac

echo ""
fi # END of ARG_RUN_INSTALL_REQUIED

## Reference pyenv https://github.com/pyenv/pyenv
if [ $ARG_RUN_INSTALL_PYTHON = 1 ]; then
    echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
    echo -e "${WHITE}    Setup pyenv & install python 3.9.10 ...${END}"
    echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
    case $(trim "$distro") in
        "Arch"*)
            vexec $VERBOSE pacman -S --needed --noconfirm base-devel openssl zlib xz graphviz
            ;;
        "Ubuntu"*)
            vexec $VERBOSE sudo apt-get install -qq \
                libssl-dev \
                graphviz \
                zlib1g-dev \
                libbz2-dev \
                libreadline-dev \
                libsqlite3-dev \
                curl \
                llvm \
                libncursesw5-dev \
                tk-dev \
                libxml2-dev \
                libxmlsec1-dev \
                libffi-dev \
                liblzma-dev
            ;;
        *)
            echo -e "${RED}  ❌  not support $distro OS to install package ${END}"
            do_exit
            ;;
    esac
    curl -L https://raw.github.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
    case $SETUP_SHELL in
        "bash")
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
            echo 'eval "$(pyenv init --path)"' >> ~/.profile
            echo 'eval "$(pyenv init -)"' >> ~/.bashrc
            ;;
        "zsh")
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile
            echo 'eval "$(pyenv init --path)"' >> ~/.zprofile

            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
            echo 'eval "$(pyenv init --path)"' >> ~/.profile

            echo 'eval "$(pyenv init -)"' >> ~/.zshrc
            ;;
        *)
            echo -e "${RED}  ❌  not support $SETUP_SHELL shell. ${END}"
            do_exit
            ;;
    esac
    # Refresh PATH enviroment
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"    # if `pyenv` is not already on PATH
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    pyenv install 3.9.10
    pyenv global 3.9.10
    pip install --upgrade pip
    pip install matplotlib aiohttp requests ijson 
    PRINT_WARNING_FLAG=1
fi
echo ""

# If '/mnt/c' in $PATH
echo $PATH | grep "/mnt/c" >/dev/null
if [ $? -eq 0 ]; then
    # If use WSL enviroment 
    if [[ "$(</proc/sys/kernel/osrelease)" == *microsoft* ]];then 
        echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
        echo -e "${WHITE}    Detect WSL enviroment${END}"
        echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
        
        case $SETUP_SHELL in
            "bash")
                CONFIG_PATH=$HOME/.profile
                # Make sure all Shell config files exist
                touch "$CONFIG_PATH"
                grep "export PATH=\$(/usr/bin/printenv PATH | /usr/bin/perl -ne 'print join(\":\", grep { \!/\\\\/mnt\\\\/\[a-z]/ } split(/:/));')" "$CONFIG_PATH" >/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}  ✅  Fix script already done in "$CONFIG_PATH" ${END}"
                else
                    echo -e "${RED}  ❌  Fix script not installed in "$CONFIG_PATH", running setup...${END}"
                    echo "" >> "$CONFIG_PATH"
                    echo "# Fix Windows PATH problem" >> "$CONFIG_PATH"
                    echo -e "export PATH=\$(/usr/bin/printenv PATH | /usr/bin/perl -ne 'print join(\":\", grep { \041/\\\/mnt\\\/[a-z]/ } split(/:/));')" >> "$CONFIG_PATH"
                    PRINT_WARNING_FLAG=1
                fi
                ;;
            "zsh")
                CONFIG_PATH=$HOME/.zprofile
                # Make sure all Shell config files exist
                touch "$CONFIG_PATH"
                grep "export PATH=\$(/usr/bin/printenv PATH | /usr/bin/perl -ne 'print join(\":\", grep { \!/\\\\/mnt\\\\/\[a-z]/ } split(/:/));')" "$CONFIG_PATH" >/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}  ✅  Fix script already done in "$CONFIG_PATH" ${END}"
                else
                    echo -e "${RED}  ❌  Fix script not installed in "$CONFIG_PATH", running setup...${END}"
                    echo "" >> "$CONFIG_PATH"
                    echo "# Fix Windows PATH problem" >> "$CONFIG_PATH"
                    echo -e "export PATH=\$(/usr/bin/printenv PATH | /usr/bin/perl -ne 'print join(\":\", grep { \041/\\\/mnt\\\/[a-z]/ } split(/:/));')" >> "$CONFIG_PATH"
                    PRINT_WARNING_FLAG=1
                fi
                ;;
            *)
                echo -e "${RED}  ❌  not support $SETUP_SHELL shell. ${END}"
                do_exit
                ;;
        esac


    fi
fi

if [[ $PRINT_WARNING_FLAG = 1 ]]; then
    echo ""
    echo -e "  ⚠  ${YELLOW}${UNDERLINE}Restart the terminal${END}  is ${BOLD}${UNDERLINE}very important${END} to reset enviroment"
    echo -e "  ⚠  You can print \$PATH use command ${YELLOW}${UNDERLINE}\`echo \$PATH\`${END}"
    echo ""
else
    echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
    echo ""
    echo -e "${CYAN}  🎉  You are all set! Enjoy Buildroot.${END}"
    echo ""
    echo -e "${WHITE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${END}"
    echo ""
fi
