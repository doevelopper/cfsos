
qstrip                   =   $(strip $(subst ",,$(1)))
MESSAGE                  =   echo "$(shell date +%Y-%m-%dT%H:%M:%S) $(TERM_BOLD)\#\#\#\#\#\#  $(call qstrip,$(1)) \#\#\#\#\#\# $(TERM_RESET)"
TERM_BOLD                :=  $(shell tput smso 2>/dev/null)
TERM_RESET               :=  $(shell tput rmso 2>/dev/null)
TERM_RED                 :=  $(shell tput setb 2 2>/dev/null)
TERM_BLINK               :=  $(shell tput blink 2>/dev/null)
TERM_REV                 :=  $(shell tput rev 2>/dev/null)
TERM_UNDERLINE           :=  $(shell tput smul 2>/dev/null)
TERM_NOUNDERLINE         :=  $(shell tput rmul 2>/dev/null)
FULL_OUTPUT              ?=  /dev/null

SHELL                    =  bash
AWK                      := awk
CP                       := cp
EGREP                    := egrep
HTML_VIEWER              := cygstart
KILL                     := /bin/kill
M4                       := m4
MV                       := mv
PDF_VIEWER               := cygstart
RM                       := rm -f
MKDIR                    := mkdir -p
LNDIR                    := lndir
SED                      := sed
SORT                     := sort
TOUCH                    := touch
XMLTO                    := xmlto
XMLTO_FLAGS              =  -o $(OUTPUT_DIR) $(XML_VERBOSE)
BISON                    := $(shell which bison || type -p bison)
UNZIP                    := $(shell which unzip || type -p unzip) -q

# Check if verbosity is ON for build process
CMD_PREFIX_DEFAULT       := @

ifeq ($(V), 1)
    Q                    :=
else
    Q                    := $(CMD_PREFIX_DEFAULT)
endif

print-help-run           =  printf "      %-30s - %s\\n" "$1" "$2"
print-help               =  $(Q)$(call print-help-run,$1,$2)

BLRT_LATEST              := https://github.com/buildroot/buildroot.git
BLRT_VERSION             =  2023.11.1
BLRT_EXT                 =  br2-cfsos
DEFCONFIG_DIR            =  $(BLRT_EXT)/configs
DEFCONFIG_DIR_FULL       =  $(PWD)/$(BLRT_EXT)/configs
DATE                     := $(shell date +%Y.%m.%d-%H%M%S --utc)
HOSTNAME                 := "fundationos"
VERSION_DATE             := $(shell date --utc +'%Y%m%d')
VERSION_DEV              := dev$(VERSION_DATE)
TOP_DIR                  := $(shell readlink -f .)



SUPPORTED_TARGETS        :=  $(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))))
TARGETS_CONFIG           :=  $(notdir $(patsubst %_defconfig,%-configure,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG_COMPILE   :=  $(notdir $(patsubst %_defconfig,%-compile,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG_TEST      :=  $(notdir $(patsubst %_defconfig,%-unit-test,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG_ITEST     :=  $(notdir $(patsubst %_defconfig,%-integration-test,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG_REL       :=  $(notdir $(patsubst %_defconfig,%-release,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BLRT_CONFIG              :=  $(notdir $(patsubst %_defconfig,%-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
LINUX_CONFIG             :=  $(notdir $(patsubst %_defconfig,%-linux-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
UBOOT_CONFIG             :=  $(notdir $(patsubst %_defconfig,%-uboot-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BUSYBOX_CONFIG           :=  $(notdir $(patsubst %_defconfig,%-busybox-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BR_SAVE_CONFIG           :=  $(notdir $(patsubst %_defconfig,%-savedefconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
REBUILD_LINUX_CFG        :=  $(notdir $(patsubst %_defconfig,%-linux-rebuild,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
REBUILD_UBOOT_CFG        :=  $(notdir $(patsubst %_defconfig,%-uboot-rebuild,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
REBUILD_BUSYBOX_CFG      :=  $(notdir $(patsubst %_defconfig,%-busybox-rebuild,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BLRT_CLEAN               :=  $(notdir $(patsubst %_defconfig,%-clean,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BLRT_DISTCLEAN           :=  $(notdir $(patsubst %_defconfig,%-distclean,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BURN_ARTIFACTS           :=  $(notdir $(patsubst %_defconfig,%-upload,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
UPGR_ARTIFACTS           :=  $(notdir $(patsubst %_defconfig,%-upgrade,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))

PRJ_STAMP_TARGETS        := \
                         .stamp_config $(foreach defconfig,$(SUPPORTED_TARGETS),.stamp_config_$(defconfig))          \
                         .stamp_source $(foreach defconfig,$(SUPPORTED_TARGETS),.stamp_source_$(defconfig))          \
                         .stamp_toolchain $(foreach defconfig,$(SUPPORTED_TARGETS),.stamp_toolchain_$(defconfig))    \
                         .stamp_os_depends $(foreach defconfig,$(SUPPORTED_TARGETS),.stamp_os_depends_$(defconfig))  \
                         .stamp_os $(foreach defconfig,$(SUPPORTED_TARGETS),.stamp_os_$(defconfig))                  \
                         .stamp_init $(foreach defconfig,$(SUPPORTED_TARGETS),.stamp_init_$(defconfig))              \
                         .stamp_updater $(foreach defconfig,$(SUPPORTED_TARGETS),.stamp_updater_$(defconfig))        \
                         .stamp_all $(foreach defconfig,$(SUPPORTED_TARGETS),.stamp_all_$(defconfig))

PRJ_PHONY_TARGETS        := \
                         config $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+config)                        \
                         source $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+source)                        \
                         toolchain $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+toolchain)                  \
                         os-depends $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+os-depends)                \
                         os $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+os)                                \
                         init $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+init)                            \
                         inconfigureit $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+configure)                            \
                         updater $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+updater)                      \
                         all $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+all)                              \
                         br-update $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+br-update)                  \
                         os-menuconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+os-menuconfig)          \
                         updater-menuconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+updater-menuconfig)\
                         menuconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+menuconfig)                \
                         legal-info $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+legal-info)                \
                         check-package                                                                               \
                         .checkpackageignore

PRJ_CLEAN_TARGETS        := \
                         $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+)                                     \
                         submodules                                                                                  \
                         clean-stamps $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+clean-stamps)            \
                         clean-target-workaround-failed-reinstall $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+clean-target-workaround-failed-reinstall) \
                         clean-target $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+clean-target)            \
                         reconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+reconfig)                    \
                         rebuild $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+rebuild)                      \
                         image $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+image)                          \
                         clean $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)+clean)                          \
                         distclean                                                                                   \
                         help

CFSOS_GOALD              :=  \
                            configure $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-configure)                        \
                            compile $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-compile)                            \
                            unit-test $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-unit-test)                        \
                            certificate $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-certificate)                    \
                            integration-test $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-integration-test)          \
                            release $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-release)                            \
                            menuconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-menuconfig)                      \
                            linux-menuconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-linux-menuconfig)          \
                            linux-rebuild $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-linux-rebuild)                \
                            uboot-menuconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-uboot-menuconfig)          \
                            uboot-rebuild $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-uboot-rebuild)                \
                            busybox-menuconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-busybox-menuconfig)      \
                            busybox-rebuild $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-busybox-rebuild)            \
                            savedefconfig $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-savedefconfig)                \
                            clean $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-clean)                                \
                            distclean $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-distclean)                        \
                            package-clean $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-package-clean)                \
                            realclean $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-realclean)                        \
                            upload $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-upload)                              \
                            upgrade $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-upgrade)                            \
                            checksum $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-checksum)                          \


## out of source build
BLRT_OOSB                =   $(PWD)/workspace
BLRT_ARTIFACTS_DIR       =   $(BLRT_OOSB)/artifacts
BLRT_PACKAGE_DIR         =   $(PWD)/dependencies
BLRT_DIR                 =   $(BLRT_PACKAGE_DIR)/buildroot-$(BLRT_VERSION)
BLRT_MAKE                :=  $(BLRT_DIR)/utils/brmake
BLRT_MAKEARGS            :=  -C $(BLRT_DIR)
BLRT_MAKEARGS            +=  BR2_EXTERNAL=$(PWD)/$(BLRT_EXT)
BLRT_MAKEARGS            +=  BR2_JLEVEL=`getconf _NPROCESSORS_ONLN`
BLRT_MAKEARGS            +=  BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc 
BLRT_MAKEARGS            +=  BR2_DL_DIR=$(BLRT_PACKAGE_DIR)/cache/dl 
BLRT_MAKEARGS            +=  BR2_TARGET_GENERIC_HOSTNAME=$(HOSTNAME) 
BLRT_MAKEARGS            +=  VERSION=$(VERSION)
#BLRT_MAKEARGS           +=  O=$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts
VERSION_GIT_EPOCH        :=  $(shell $(GIT) log -1 --format=%at 2> /dev/null)


# Time steps
define step_time
    printf "%s:%-5.5s:%-20.20s: %s\n"               \
           "$$(date +%s.%N)" "$(1)" "$(2)" "$(3)"      \
           >>"$(BUILD_DIR)/build-time.log"
endef

word-dot                 = $(word $2,$(subst ., ,$1))
UC                       = $(shell echo '$1' | tr '[:lower:]' '[:upper:]')