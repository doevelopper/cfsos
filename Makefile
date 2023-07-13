
.DEFAULT_GOAL:=help

include br-external.conf

# Courtesy to 
#	https://github.com/fhunleth/bbb-buildroot-fwup/blob/master/Makefile
#   https://github.com/RosePointNav/nerves-sdk/blob/master/Makefile
#   https://github.com/jens-maus/RaspberryMatic/blob/master/Makefile
##################################################################################################################################


.NOTPARALLEL: $(SUPPORTED_TARGETS) $(addsuffix -release, $(SUPPORTED_TARGETS)) $(addsuffix -clean, $(SUPPORTED_TARGETS)) build-all clean-all release-all
.PHONY: all build release clean cleanall distclean help updatePkg

$(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz:
	@$(call MESSAGE,"BLRT [Downloading buildroot-$(BUILDROOT_VERSION).tar.gz to $(OOSB)/]")
	@mkdir -pv $(OOSB)
	wget https://github.com/buildroot/buildroot/archive/refs/tags/$(BUILDROOT_VERSION).tar.gz -O $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
	echo "$(BUILDROOT_SHA256)  $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz" > $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz.sign
	shasum -a 256 -c $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz.sign

# $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz:
# 	@$(call MESSAGE,"BLRT [Downloading buildroot-$(BUILDROOT_VERSION).tar.xz to $(OOSB)/]")
# 	@wget https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.xz  -O $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
# 	@wget https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.xz.sign  -O $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.xz.sign
# 	@cat $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.xz.sign | grep SHA1: | sed 's/^SHA1: //' | shasum -c

$(OOSB)/buildroot-$(BUILDROOT_VERSION): | $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
	@$(call MESSAGE,"BLRT [Extracting buildroot-$(BUILDROOT_VERSION)] $@ ")
	@cd $(OOSB) && if [ ! -d $@ ]; then tar xf $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz; fi
# for p in $(sort $(wildcard buildroot-patches/*.patch)); do echo "\nApplying $${p}"; patch -d $(OOSB)/buildroot-$(BUILDROOT_VERSION) --remove-empty-files -p1 < $${p} || exit 127; [ ! -x $${p%.*}.sh ] || $${p%.*}.sh buildroot-$(BUILDROOT_VERSION); done; fi

$(OOSB)/.buildroot-downloaded: $(OOSB)/buildroot-$(BUILDROOT_VERSION)
	@$(call MESSAGE,"BLRT [Caching downloaded files in $(PROJECT_BR_DL_DIR).]")
	@mkdir -p $(PROJECT_BR_DL_DIR)
	@touch $(OOSB)/.buildroot-downloaded

$(OOSB)/.buildroot-patched: $(OOSB)/.buildroot-downloaded
	@$(call MESSAGE,"BLRT [Patching buildroot-$(BUILDROOT_VERSION)]")
	# $(OOSB)/buildroot-$(BUILDROOT_VERSION)/support/scripts/apply-patches.sh $(OOSB)/buildroot-$(BUILDROOT_VERSION) $(BUILDROOT_EXT)/patches/buildroot || exit 1
	touch $(OOSB)/.buildroot-patched

	# If there's a user dl directory, symlink it to avoid the big download
	if [ -d $(PROJECT_BR_DL_DIR) -a ! -e $(OOSB)/buildroot-$(BUILDROOT_VERSION)/dl ]; then \
		ln -s $(PROJECT_BR_DL_DIR) $(OOSB)/buildroot-$(BUILDROOT_VERSION)/dl; \
	fi

$(OOSB)/build-$(TARGET_BOARD): | $(OOSB)/buildroot-$(BUILDROOT_VERSION) $(OOSB)/.buildroot-patched
	@$(call MESSAGE,"BLRT [Creating $(TARGET_BOARD) build directory.]")
	@mkdir $(OOSB)/build-$(TARGET_BOARD)

$(OOSB)/build-$(TARGET_BOARD)/.config: | $(OOSB)/build-$(TARGET_BOARD)
	@$(call MESSAGE,"BLRT [Generating config for $(TARGET_BOARD)  $@")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) $(TARGET_BOARD)_defconfig


.PHONY: $(addsuffix -menuconfig,$(TARGET_BOARD))
$(addsuffix -menuconfig,$(TARGET_BOARD)): %-menuconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"BLRT [Change buildroot configuration for $(TARGET_BOARD) board]")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) menuconfig
	@echo
	@echo "!!! Important !!!"
	@echo "1. $(OOSB)/build-$(TARGET_BOARD)/.config has NOT been updated."
	@echo "   Changes will be lost if you run 'make distclean'."
	@echo "   Run $(TERM_BOLD) 'make $(addsuffix -savedefconfig,$(TARGET_BOARD))' $(TERM_RESET) to update."
	@echo "2. Buildroot normally requires you to run 'make clean' and 'make' after"
	@echo "   changing the configuration. You don't technically have to do this,"
	@echo "   but if you're new to Buildroot, it's best to be safe."

.PHONY: $(addsuffix -savedefconfig,$(TARGET_BOARD))
$(addsuffix -savedefconfig,$(TARGET_BOARD)): %-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"BLRT [Saving $(TARGET_BOARD)] defautl config")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) savedefconfig

.PHONY: $(addsuffix -linux-menuconfig,$(TARGET_BOARD))
$(addsuffix -linux-menuconfig,$(TARGET_BOARD)): %-linux-menuconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Linux kernel configuration.] $*")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) linux-menuconfig
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) linux-savedefconfig
	@echo
	@echo Going to update your board/$(TARGET_BOARD)/configs/linux.config. If you do not have one,
	@echo you will get an error shortly. You will then have to make one and update,
	@echo your buildroot configuration to use it.
	@echo
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) linux-update-defconfig

.PHONY: $(addsuffix -linux-savedefconfig,$(TARGET_BOARD))
$(addsuffix -linux-savedefconfig,$(TARGET_BOARD)): %-linux-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Linux Savedefconfig]")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) linux-update-defconfig || \
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) linux-savedefconfig

.PHONY: $(addsuffix -uboot-menuconfig,$(TARGET_BOARD))
$(addsuffix -uboot-menuconfig,$(TARGET_BOARD)): %-uboot-menuconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Bootloader configuration.] $*")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) uboot-menuconfig
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) uboot-savedefconfig
	@echo
	@echo Going to update your board/$(TARGET_BOARD)/configs/uboot.config. If you do not have one,
	@echo you will get an error shortly. You will then have to make one and update,
	@echo your buildroot configuration to use it.
	@echo
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) uboot-update-defconfig

.PHONY: $(addsuffix -uboot-savedefconfig,$(TARGET_BOARD))
$(addsuffix -uboot-savedefconfig,$(TARGET_BOARD)): %-uboot-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Uboot Savedefconfig]")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) uboot-update-defconfig || \
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) uboot-savedefconfig

.PHONY: $(addsuffix -busybox-menuconfig,$(TARGET_BOARD))
$(addsuffix -busybox-menuconfig,$(TARGET_BOARD)): %-busybox-menuconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Busybox configuration.] $*")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD)/ busybox-menuconfig
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) busybox-savedefconfig
	@echo
	@echo Going to update your board/$(TARGET_BOARD)/configs/busybox.config. If you do not have one,
	@echo you will get an error shortly. You will then have to make one and update,
	@echo your buildroot configuration to use it.
	@echo
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) busybox-update-defconfig

.PHONY: $(addsuffix -busybox-savedefconfig,$(TARGET_BOARD))
$(addsuffix -busybox-savedefconfig,$(TARGET_BOARD)): %-busybox-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Busybox Savedefconfig]")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) busybox-update-defconfig || \
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) busybox-savedefconfig

# linux-diff-config linux-rebuild linux-reinstall:
# 	@echo "[$@ $(TARGET_BOARD)]"
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) $@
##################################################################################################################################
#
#    					Build
#
##################################################################################################################################
.PHONY: $(addsuffix -compile,$(TARGET_BOARD))
$(addsuffix -compile,$(TARGET_BOARD)): | $(OOSB)/buildroot-$(BUILDROOT_VERSION) $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [ Compiling]")
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) 
#	> $(CURRENT_LOG) 2>&1 && cat $(CURRENT_LOG) >> $(ALL_LOG)
	@$(call MESSAGE,"$(TARGET_BOARD) [ Copying builds artifacts to $(ARTIFACTS_DIR)]")
#	@mkdir -pv $(ARTIFACTS_DIR)/$(TARGET_BOARD)
#	@cp -Rv $(OOSB)/build-$(TARGET_BOARD)/images/ $(ARTIFACTS_DIR)/$(TARGET_BOARD)
	@$(call MESSAGE,"$(TARGET_BOARD) [ Done]")


.PHONY: $(addsuffix -unit-testing,$(TARGET_BOARD))
$(addsuffix -unit-testing,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Unit Testing]")

.PHONY: $(addsuffix -integration-testing,$(TARGET_BOARD))
$(addsuffix -integration-testing,$(TARGET_BOARD)): | $(addsuffix -unit-testing,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Integration Testing]")

.PHONY: $(addsuffix -package,$(TARGET_BOARD))
$(addsuffix -package,$(TARGET_BOARD)): | $(addsuffix -integration-testing,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Packaging]")

##################################################################################################################################
#
#    					BR2 Clean goals
#
##################################################################################################################################

clean-all: $(addsuffix -clean, $(TARGET_BOARD))
$(addsuffix -clean, $(TARGET_BOARD)): %:
	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) PRODUCT=$(subst -clean,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) clean

clean:
	@$(call MESSAGE,"$(TARGET_BOARD) [ Cleaning $(OOSB)/build-$(TARGET_BOARD)]")
	@rm -rf $(OOSB)/build-$(TARGET_BOARD)

distclean: clean-all
	@$(call MESSAGE,"$(TARGET_BOARD) [ Clean everything start]")
	@rm -rf $(OOSB)/buildroot-$(BUILDROOT_VERSION)
	@rm -f $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.*
	@rm -rf $(OOSB)/.buildroot-patched $(OOSB)/.buildroot-downloaded $(OOSB)

##################################################################################################################################
#
#    					Caluculate Checksum Target
#
##################################################################################################################################

.PHONY: help
help:
	@echo "  Version $$(git describe --always), Copyright (C) 2023 AHL"
	@echo "  Comes with ABSOLUTELY NO WARRANTY; for details see file LICENSE."
	@echo "  SPDX-License-Identifier: GPL-2.0-only"
	@echo
	@echo "$(TERM_BOLD)Build Environment$(TERM_RESET)"
	@echo
	@echo "Usage:"
	@echo "  	$(TERM_BOLD)$(MAKE) <product>$(TERM_RESET): build+create image for selected product"
	@echo "  	$(TERM_BOLD)$(MAKE) build-all$(TERM_RESET): run build for all supported products"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) <product>-release$(TERM_RESET): build+create release archive for product"
	@echo "  	$(TERM_BOLD)$(MAKE) release-all$(TERM_RESET): build+create release archive for all supported products"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) <product>-check$(TERM_RESET): run ci consistency check for product"
	@echo "  	$(TERM_BOLD)$(MAKE) check-all$(TERM_RESET): run ci consistency check all supported platforms"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) <product>-clean$(TERM_RESET): remove build directory for product"
	@echo "  	$(TERM_BOLD)$(MAKE) clean-all$(TERM_RESET): remove build directories for all supported platforms"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) distclean$(TERM_RESET): clean everything (all build dirs and buildroot sources)"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> menuconfig$(TERM_RESET): change buildroot config options"
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> savedefconfig$(TERM_RESET): update buildroot defconfig file"
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> linux-menuconfig$(TERM_RESET): change linux kernel config option"
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> linux-update-defconfig$(TERM_RESET): update linux kernel defconfig file"
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> mbusybox-menuconfig$(TERM_RESET): change busybox config options"
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> busybox-update-config$(TERM_RESET): update busybox defconfig file"
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> uboot-menuconfig$(TERM_RESET): change u-boot config options"
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> uboot-update-defconfig$(TERM_RESET): update u-boot defconfig file"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) TARGET_BOARD=<product> legal-info$(TERM_RESET): update legal information file"
	@echo
	@echo "Supported targets:"
#	@$(foreach defconfig,$(SUPPORTED_TARGETS), \
#		echo '   	$(TERM_BOLD)$(defconfig)$(TERM_RESET)'; \
#	)
	@$(foreach b, $(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))), \
		printf "  	%-29s - Build configuration for %s\\n" $(b) $(b:_defconfig=);)
	@echo
	@echo "Packages targets:"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) pkg-all$(TERM_RESET)"
	@echo "  	$(TERM_BOLD)$(MAKE) <package>-clean$(TERM_RESET)"
	@echo "  	$(TERM_BOLD)$(MAKE) <package>-dirclean$(TERM_RESET)"
	@echo "  	$(TERM_BOLD)$(MAKE) <package>-rebuild$(TERM_RESET)"
	@echo "  	$(TERM_BOLD)$(MAKE) <package>-test$(TERM_RESET)"
	@echo "  	$(TERM_BOLD)$(MAKE) <package>-reconfigure$(TERM_RESET)"
	@echo "  	$(TERM_BOLD)$(MAKE) <package>-reinstall$(TERM_RESET)"
