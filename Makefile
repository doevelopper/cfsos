
.DEFAULT_GOAL:=help

# This file is part of CFSOS.
#
#    CFSOS is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    CFSOS is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with CFSOS.  If not, see <http://www.gnu.org/licenses/>. 2

include br-external.conf

# Courtesy to 
#	https://github.com/fhunleth/bbb-buildroot-fwup/blob/master/Makefile
#   https://github.com/RosePointNav/nerves-sdk/blob/master/Makefile
#   https://github.com/jens-maus/RaspberryMatic/blob/master/Makefile
##################################################################################################################################


.NOTPARALLEL: $(SUPPORTED_TARGETS) $(addsuffix -release, $(SUPPORTED_TARGETS)) $(addsuffix -clean, $(SUPPORTED_TARGETS)) build-all clean-all release-all
.PHONY: all build release clean cleanall distclean help updatePkg

$(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz.sign:
	@$(call MESSAGE,"BLRT [Downloading signature $@ ]")
	@mkdir -pv $(OOSB)
	@mkdir -pv $(BR2_CCACHE_DIR)
	curl --output $@ https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.gz.sign

$(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz: | $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz.sign
	@$(call MESSAGE,"BLRT [Downloading build tool $@ ]")
	curl --output $@ https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.gz
#	@cd $(OOSB) && cat buildroot-$(BUILDROOT_VERSION).tar.xz.sign | grep SHA1: | sed 's/^SHA1: //' | shasum -c
#	@cd $(OOSB) && cat buildroot-$(BUILDROOT_VERSION).tar.xz.sign | grep SHA256: | sed 's/^SHA256: //' | shasum -a 256 -c

# $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz:
# 	@$(call MESSAGE,"BLRT [Downloading buildroot-$(BUILDROOT_VERSION).tar.gz to $(OOSB)/]")
# 	@mkdir -pv $(OOSB)
# 	@mkdir -pv $(BR2_CCACHE_DIR)
# 	wget https://github.com/buildroot/buildroot/archive/refs/tags/$(BUILDROOT_VERSION).tar.gz -O $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
# 	echo "$(BUILDROOT_SHA256)  $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz" > $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz.sign
# 	shasum -a 256 -c $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz.sign

# $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz:
# 	@$(call MESSAGE,"BLRT [Downloading buildroot-$(BUILDROOT_VERSION).tar.xz to $(OOSB)/]")
# 	@mkdir -pv $(OOSB)
# 	@mkdir -pv $(BR2_CCACHE_DIR)
# 	@wget https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.xz 		-O $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
# 	@wget https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.xz.sign  	-O $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.xz.sign
# 	@cd $(OOSB) && cat buildroot-$(BUILDROOT_VERSION).tar.xz.sign | grep SHA1: | sed 's/^SHA1: //' | shasum -c

$(OOSB)/buildroot-$(BUILDROOT_VERSION): | $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
	@$(call MESSAGE,"BLRT [Extracting buildroot-$(BUILDROOT_VERSION)] $@ ")
	@cd $(OOSB) && if [ ! -d $@ ]; then tar xf $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz; fi
# @if [ -d $(BR2_EXTERNAL)/patches/buildroot ]; then\
# 	$(call MESSAGE,"BLRT [Patching buildroot ]") \
#    	for p in $(sort $(wildcard buildroot-patches/*.patch)); do echo "\nApplying $${p}"; patch -d $(OOSB)/buildroot-$(BUILDROOT_VERSION) --remove-empty-files -p1 < $${p} || exit 127; [ ! -x $${p%.*}.sh ] || $${p%.*}.sh buildroot-$(BUILDROOT_VERSION); done; fi;\
# fi

$(OOSB)/.buildroot-downloaded: $(OOSB)/buildroot-$(BUILDROOT_VERSION)
	@$(call MESSAGE,"BLRT [Caching downloaded files in $(PROJECT_BR_DL_DIR).]")
	@mkdir -p $(PROJECT_BR_DL_DIR)
	@touch $@


$(OOSB)/.buildroot-patched: $(OOSB)/.buildroot-downloaded
	@$(call MESSAGE,"BLRT [Patching buildroot-$(BUILDROOT_VERSION)]")
#	$(BLRT_DIR)/support/scripts/apply-patches.sh $(OOSB)/buildroot-$(BUILDROOT_VERSION) $(BUILDROOT_EXT)/patches/buildroot || exit 1
	@touch $@

# 	# If there's a user dl directory, symlink it to avoid the big download
# 	if [ -d $(PROJECT_BR_DL_DIR) -a ! -e $(OOSB)/buildroot-$(BUILDROOT_VERSION)/dl ]; then \
# 		ln -s $(PROJECT_BR_DL_DIR) $(OOSB)/buildroot-$(BUILDROOT_VERSION)/dl; \
# 	fi

$(OOSB)/$(TARGET_BOARD)-build-artifacts: | $(OOSB)/buildroot-$(BUILDROOT_VERSION) $(OOSB)/.buildroot-patched
	@$(call MESSAGE,"BLRT [Creating $(TARGET_BOARD) build directory.]")
	@mkdir $(OOSB)/$(TARGET_BOARD)-build-artifacts
	@touch $@

$(OOSB)/$(TARGET_BOARD)-build-artifacts/.config: | $(OOSB)/$(TARGET_BOARD)-build-artifacts
	@$(call MESSAGE,"BLRT [Default config for $(TARGET_BOARD)  $@")
	@$(MAKE) help
#	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts PRODUCT_VERSION=$(PRODUCT_VERSION) $(TARGET_BOARD)_defconfig
# @echo $(BUILDROOT_OPTIONS)  
# @echo O=$(OOSB)/$(TARGET_BOARD)-build-artifacts 
# @echo PRODUCT_VERSION=$(PRODUCT_VERSION) 
# @echo $(TARGET_BOARD)_defconfig

$(TARGET_BOARD)-configure: | $(OOSB)/$(TARGET_BOARD)-build-artifacts/.config
	@$(call MESSAGE,"BLRT [$(TARGET_BOARD) default configuration generated...")

.PHONY: $(addsuffix -menuconfig,$(TARGET_BOARD))
$(addsuffix -menuconfig,$(TARGET_BOARD)): %-menuconfig: $(TARGET_BOARD)-configure
	@$(call MESSAGE,"BLRT [Change buildroot configuration for $(TARGET_BOARD) board]")
#	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts PRODUCT_VERSION=$(PRODUCT_VERSION) menuconfig
	@echo
	@echo "!!! Important !!!"
	@echo "1. $(TARGET_BOARD)-configure has NOT been updated."
	@echo "   Changes will be lost if you run 'make distclean'."
	@echo "   Run $(TERM_BOLD) 'make $(addsuffix -savedefconfig,$(TARGET_BOARD))' $(TERM_RESET) to update."
	@echo "2. Buildroot normally requires you to run 'make clean' and 'make' after"
	@echo "   changing the configuration. You don't technically have to do this,"
	@echo "   but if you're new to Buildroot, it's best to be safe."

.PHONY: $(addsuffix -savedefconfig,$(TARGET_BOARD))
$(addsuffix -savedefconfig,$(TARGET_BOARD)): %-savedefconfig: $(TARGET_BOARD)-configure
	@$(call MESSAGE,"BLRT [Saving $(TARGET_BOARD)] defautl config")
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts PRODUCT_VERSION=$(PRODUCT_VERSION) savedefconfig

.PHONY: $(addsuffix -linux-menuconfig,$(TARGET_BOARD))
$(addsuffix -linux-menuconfig,$(TARGET_BOARD)): %-linux-menuconfig: $(TARGET_BOARD)-configure
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Linux kernel configuration.] $*")
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts linux-menuconfig
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts linux-savedefconfig
# 	@echo
# 	@echo Going to update your board/$(TARGET_BOARD)/configs/linux.config. If you do not have one,
# 	@echo you will get an error shortly. You will then have to make one and update,
# 	@echo your buildroot configuration to use it.
# 	@echo
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts linux-update-defconfig

.PHONY: $(addsuffix -linux-savedefconfig,$(TARGET_BOARD))
$(addsuffix -linux-savedefconfig,$(TARGET_BOARD)): %-linux-savedefconfig: $(TARGET_BOARD)-configure
	@$(call MESSAGE,"$(TARGET_BOARD) [Linux Savedefconfig]")
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts linux-update-defconfig || \
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts linux-savedefconfig

.PHONY: $(addsuffix -uboot-menuconfig,$(TARGET_BOARD))
$(addsuffix -uboot-menuconfig,$(TARGET_BOARD)): %-uboot-menuconfig: $(TARGET_BOARD)-configure
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Bootloader configuration.] $*")
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts uboot-menuconfig
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts uboot-savedefconfig
# 	@echo
# 	@echo Going to update your board/$(TARGET_BOARD)/configs/uboot.config. If you do not have one,
# 	@echo you will get an error shortly. You will then have to make one and update,
# 	@echo your buildroot configuration to use it.
# 	@echo
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts uboot-update-defconfig

.PHONY: $(addsuffix -uboot-savedefconfig,$(TARGET_BOARD))
$(addsuffix -uboot-savedefconfig,$(TARGET_BOARD)): %-uboot-savedefconfig: $(TARGET_BOARD)-configure
	@$(call MESSAGE,"$(TARGET_BOARD) [Uboot Savedefconfig]")
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts uboot-update-defconfig || \
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts uboot-savedefconfig

.PHONY: $(addsuffix -busybox-menuconfig,$(TARGET_BOARD))
$(addsuffix -busybox-menuconfig,$(TARGET_BOARD)): %-busybox-menuconfig: $(TARGET_BOARD)-configure
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Busybox configuration.] $*")
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts/ busybox-menuconfig
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts busybox-savedefconfig
# 	@echo
# 	@echo Going to update your board/$(TARGET_BOARD)/configs/busybox.config. If you do not have one,
# 	@echo you will get an error shortly. You will then have to make one and update,
# 	@echo your buildroot configuration to use it.
# 	@echo
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts busybox-update-defconfig

.PHONY: $(addsuffix -busybox-savedefconfig,$(TARGET_BOARD))
$(addsuffix -busybox-savedefconfig,$(TARGET_BOARD)): %-busybox-savedefconfig: $(TARGET_BOARD)-configure
	@$(call MESSAGE,"$(TARGET_BOARD) [Busybox Savedefconfig]")
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts busybox-update-defconfig || \
# 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts busybox-savedefconfig

# # linux-diff-config linux-rebuild linux-reinstall:
# # 	@echo "[$@ $(TARGET_BOARD)]"
# # 	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts $@
# ##################################################################################################################################
# #
# #    					Build
# #
# ##################################################################################################################################
.PHONY: $(addsuffix -compile,$(TARGET_BOARD))
$(addsuffix -compile,$(TARGET_BOARD)): | $(OOSB)/buildroot-$(BUILDROOT_VERSION) $(TARGET_BOARD)-configure
	@$(call MESSAGE,"$(TARGET_BOARD) [ Compiling artifacts]")
#	@$(BUILDROOT_OPTIONS)  O=$(OOSB)/$(TARGET_BOARD)-build-artifacts 
# #	> $(CURRENT_LOG) 2>&1 && cat $(CURRENT_LOG) >> $(ALL_LOG)
# 	@$(call MESSAGE,"$(TARGET_BOARD) [ Copying builds artifacts to $(ARTIFACTS_DIR)]")
# #	@mkdir -pv $(ARTIFACTS_DIR)/$(TARGET_BOARD)
# #	@cp -Rv $(OOSB)/$(TARGET_BOARD)-build-artifacts/images/ $(ARTIFACTS_DIR)/$(TARGET_BOARD)
# 	@echo
# 	@$(call MESSAGE,"$(TARGET_BOARD) [ Done! \@see $(OOSB)/$(TARGET_BOARD)-build-artifacts/images/]")


.PHONY: $(addsuffix -unit-testing,$(TARGET_BOARD))
$(addsuffix -unit-testing,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Unit Testing]")

.PHONY: $(addsuffix -integration-testing,$(TARGET_BOARD))
$(addsuffix -integration-testing,$(TARGET_BOARD)): | $(addsuffix -unit-testing,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Integration Testing]")

.PHONY: $(addsuffix -coverage-testing,$(TARGET_BOARD))
$(addsuffix -coverage-testing,$(TARGET_BOARD)): | $(addsuffix -unit-testing,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Integration Testing]")

.PHONY: $(addsuffix -package,$(TARGET_BOARD))
$(addsuffix -package,$(TARGET_BOARD)): | $(addsuffix -integration-testing,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Packaging]")

.PHONY: $(addsuffix -burn,$(TARGET_BOARD))
$(addsuffix -burn,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Replace everything on the SDCard with new bits]")
# 	@$(OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/rauc --version
# 	@$(OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/fwup --version
# ## /host/usr/bin/fwup -a -i $(firstword $(wildcard buildroot/output/images/*.fw)) -t complete

# # Upgrade the image on the SDCard (app data won't be removed)
# # This is usually the fastest way to update an SDCard that's already
# # been programmed. It won't update bootloaders, so if something is
# # really messed up, burn-complete may be better.
.PHONY: $(addsuffix -upgrade,$(TARGET_BOARD))
$(addsuffix -upgrade,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Upgrading taget $(TARGET_BOARD)]")
# 	@fakeroot $(OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/fwup -a -i $(firstword $(wildcard $(OOSB)/$(TARGET_BOARD)-build-artifacts/output/images/*.fw)) -t upgrade
# 	@fakeroot $(OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/fwup -y -a -i /tmp/finalize.fw -t on-reboot
# 	@fakeroot rm /tmp/finalize.fw

.PHONY: $(addsuffix -updater,$(TARGET_BOARD))
$(addsuffix -updater,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	@$(call MESSAGE,"$(TARGET_BOARD) [ Updating $(TARGET_BOARD) packages]")
# 	@echo "=== $@ ==="
# 	@if grep -q 'BR2_PACKAGE_SWUPDATE=y' $(OOSB)/$(TARGET_BOARD)-build-artifacts/.config; then \
# 		echo "--- (swupdate) $@ ---" ; \
# 	else \
# 		echo "--- (skip swupdate) $@ ---" ; \
# 	fi

# ##################################################################################################################################
# #
# #    					BR2 Clean goals
# ##
# ##################################################################################################################################

.PHONY: $(addsuffix -clean, $(TARGET_BOARD))
$(addsuffix -clean, $(TARGET_BOARD)): %:
	@if [ -d $(OOSB)/$(TARGET_BOARD)-build-artifacts ]; then\
		$(call MESSAGE,"$(TARGET_BOARD) [ Clean $(SUPPORTED_TARGETS) $@ ]") \
       	$(BUILDROOT_OPTIONS) O=$(OOSB)/$(TARGET_BOARD)-build-artifacts PRODUCT=$(subst -clean,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) clean;\
    fi

.PHONY: $(addsuffix -distclean, $(TARGET_BOARD))
$(addsuffix -distclean, $(TARGET_BOARD)): %:
	@if [ -d $(OOSB)/$(TARGET_BOARD)-build-artifacts ]; then\
		$(call MESSAGE,"$(TARGET_BOARD) [ Dist clean $(SUPPORTED_TARGETS) $@ ]") \
       	$(BUILDROOT_OPTIONS) O=$(OOSB)/$(TARGET_BOARD)-build-artifacts PRODUCT=$(subst -clean,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) distclean;\
    fi

dangerous-reset:
	@$(call MESSAGE,"[ BLRT Wipe everything]")
	@rm -rf $(OOSB)/buildroot-$(BUILDROOT_VERSION)
	@rm -f $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.*
	@rm -rf $(OOSB)/.buildroot-patched $(OOSB)/.buildroot-downloaded $(OOSB)


#	@$(BUILDROOT_OPTIONS) O=$(OOSB)/$(TARGET_BOARD)-build-artifacts PRODUCT=$(subst -clean,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) clean
# clean:
# 	@$(call MESSAGE,"$(TARGET_BOARD) [ Cleaning $(OOSB)/$(TARGET_BOARD)-build-artifacts]")
# 	@rm -rf $(OOSB)/$(TARGET_BOARD)-build-artifacts
# ##################################################################################################################################
# #
# #    					Caluculate Checksum Target
# #
# ##################################################################################################################################

.PHONY: help
help:
	@echo "  Version $$(git describe --always), Copyright (C) 2023 AHL"
	@echo "  Comes with ABSOLUTELY NO WARRANTY; for details see file LICENSE."
	@echo "  SPDX-License-Identifier: GPL-2.0-only"
	@echo
	@echo "$(TERM_BOLD)Build Environment$(TERM_RESET)"
	@echo
	@echo "Usage:"
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>$(TERM_RESET): build+create image for selected target board"
	@echo "  	$(TERM_BOLD)$(MAKE) build-all$(TERM_RESET): run build for all supported products"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-release$(TERM_RESET): build+create release archive for target board"
	@echo "  	$(TERM_BOLD)$(MAKE) release-all$(TERM_RESET): build+create release archive for all supported products"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-check$(TERM_RESET): run ci consistency check for target board"
	@echo "  	$(TERM_BOLD)$(MAKE) check-all$(TERM_RESET): run ci consistency check all supported platforms"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-clean$(TERM_RESET): remove build directory for target board"
	@echo "  	$(TERM_BOLD)$(MAKE) clean-all$(TERM_RESET): remove build directories for all supported platforms"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) distclean$(TERM_RESET): clean everything (all build dirs and buildroot sources)"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-menuconfig$(TERM_RESET): change buildroot config options"
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-savedefconfig$(TERM_RESET): update buildroot defconfig file"
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-linux-menuconfig$(TERM_RESET): change linux kernel config option"
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-linux-update-defconfig$(TERM_RESET): update linux kernel defconfig file"
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-mbusybox-menuconfig$(TERM_RESET): change busybox config options"
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-busybox-update-config$(TERM_RESET): update busybox defconfig file"
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-uboot-menuconfig$(TERM_RESET): change u-boot config options"
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-uboot-update-defconfig$(TERM_RESET): update u-boot defconfig file"
	@echo
	@echo "  	$(TERM_BOLD)$(MAKE) <target_board>-legal-info$(TERM_RESET): update legal information file"
	@echo
	@echo "Supported targets:"
#	@$(foreach defconfig,$(SUPPORTED_TARGETS), \
#		echo '   	$(TERM_UNDERLINE)$(defconfig)$(TERM_NOUNDERLINE)'; \
#	)
	@$(foreach b, $(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))), \
		printf "  	%-29s - Build configuration for %s\\n" $(b) $(b:_defconfig=); \
	)
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
