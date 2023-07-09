https://bootlin.com/~thomas/site/buildroot/adding-packages.html

#
#    Buildroot settings
#
##################################################################################################################################
# ifneq ($(BUILDROOT_LATEST),)
# 	$(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz:  cloning-buildroot-latest downloading-buildroot-$(BUILDROOT_VERSION)
# endif

# .PHONY: $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
# $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz:
# 	@$(call MESSAGE,"BLRT [Retrieving Buildroot.]")

# .PHONY: cloning-buildroot-latest
# cloning-buildroot-latest:
# 	@$(call MESSAGE,"BLRT [Cloning latest Buildroot to $(OOSB)/.]")

# .PHONY: downloading-buildroot-$(BUILDROOT_VERSION)
# downloading-buildroot-$(BUILDROOT_VERSION):
# 	@$(call MESSAGE,"BLRT [downloading buildroot-$(BUILDROOT_VERSION).tar.gz to $(OOSB)/]")

# ifneq ($(BUILDROOT_LATEST),)
# 	$(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz: cloning-buildroot-latest
# #else
# #	 $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz: downloading-buildroot-$(BUILDROOT_VERSION)
# endif


$(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz:
	@$(call MESSAGE,"BLRT [Retrieving Buildroot.]")
	@mkdir -p $(OOSB)
ifneq ($(BUILDROOT_LATEST),)
	@$(call MESSAGE,"BLRT [Cloning latest Buildroot.]")
# # 	@if [ ! -d $(OOSB)/buildroot-$(BUILDROOT_VERSION) ]; then git clone --depth=1 https://github.com/buildroot/buildroot $(OOSB)/buildroot-$(BUILDROOT_VERSION); fi
else
	@$(call MESSAGE,"BLRT [Downloading buildroot-$(BUILDROOT_VERSION).tar.gz  to $(OOSB)/]")
	wget https://github.com/buildroot/buildroot/archive/refs/tags/$(BUILDROOT_VERSION).tar.gz -O $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
	echo "$(BUILDROOT_SHA256)  $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz" > $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz.sign
	shasum -a 256 -c $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz.sign
endif


$(OOSB)/buildroot-$(BUILDROOT_VERSION): | $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz
	@$(call MESSAGE,"BLRT [Patching buildroot-$(BUILDROOT_VERSION)]")
#	@if [ ! -d $@ ]; then tar xf $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.gz; for p in $(sort $(wildcard buildroot-patches/*.patch)); do echo "\nApplying $${p}"; patch -d $(OOSB)/buildroot-$(BUILDROOT_VERSION) --remove-empty-files -p1 < $${p} || exit 127; [ ! -x $${p%.*}.sh ] || $${p%.*}.sh $(OOSB)/buildroot-$(BUILDROOT_VERSION); done; fi

.buildroot-downloaded: $(OOSB)/buildroot-$(BUILDROOT_VERSION)
	@$(call MESSAGE,"BLRT [Caching downloaded files in $(PROJECT_BR_DL_DIR).]")
	@mkdir -p $(PROJECT_BR_DL_DIR)
	@touch .buildroot-downloaded

.buildroot-patched: .buildroot-downloaded ## Apply patches that either haven't been submitted or merged upstream yet
	@$(call MESSAGE,"BLRT [Apply patches that either haven't been submitted or merged upstream yet.]")
#	$(OOSB)/buildroot-$(BUILDROOT_VERSION)/support/scripts/apply-patches.sh $(OOSB)/buildroot-$(BUILDROOT_VERSION) patches/buildroot || exit 1
	@touch .buildroot-patched
#	# If there's a user dl directory, symlink it to avoid the big download

#	if [ -d $(PROJECT_BR_DL_DIR) -a ! -e buildroot/dl ]; then \
#		ln -s $(PROJECT_BR_DL_DIR) buildroot/dl; \
#	fi

reset-buildroot: .buildroot-downloaded
	@$(call MESSAGE,"BLRT [Reset buildroot to a pristine condition so that the patches can be applied again.]")
#	cd $(OOSB)/buildroot-$(BUILDROOT_VERSION) && git clean -fdx && git reset --hard
	@rm -vf .buildroot-patched

update-patches: reset-buildroot .buildroot-patched

$(OOSB)/build-$(TARGET_BOARD): | $(OOSB)/buildroot-$(BUILDROOT_VERSION) .buildroot-downloaded
	@$(call MESSAGE,"BLRT [Creating build-$(TARGET_BOARD) as build's output")
#	mkdir -pv $(OOSB)/build-$(TARGET_BOARD)

$(OOSB)/build-$(TARGET_BOARD)/.config: | $(OOSB)/build-$(TARGET_BOARD) .buildroot-patched
	@$(call MESSAGE,"BLRT [Generating config for $(TARGET_BOARD)  $@")
#	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) $(TARGET_BOARD)_defconfig

##################################################################################################################################
#
#    Buildroot generic goals
#
##################################################################################################################################

# .PHONY: menuconfig
# menuconfig: $(OOSB)/buildroot-$(BUILDROOT_VERSION) $(OOSB)/build-$(TARGET_BOARD)/.config
# 	@echo
# 	@$(call MESSAGE,"[Configure $(TARGET_BOARD)]")
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) menuconfig


# Change buildroot configuration for the specific board
.PHONY: $(addsuffix -menuconfig,$(TARGET_BOARD))
$(addsuffix -menuconfig,$(TARGET_BOARD)): %-menuconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"BLRT [Configure $(TARGET_BOARD)]")
#	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) menuconfig
	@echo
	@echo "!!! Important !!!"
	@echo "1. $(OOSB)/build-$(TARGET_BOARD)/.config has NOT been updated."
	@echo "   Changes will be lost if you run 'make distclean'."
	@echo "   Run '$(addsuffix -savedefconfig,$(TARGET_BOARD))' to update."
	@echo "2. Buildroot normally requires you to run 'make clean' and 'make' after"
	@echo "   changing the configuration. You don't technically have to do this,"
	@echo "   but if you're new to Buildroot, it's best to be safe."

.PHONY: $(addsuffix -savedefconfig,$(TARGET_BOARD))
$(addsuffix -savedefconfig,$(TARGET_BOARD)): %-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"BLRT [Saving $(TARGET_BOARD)] defautl config")

# .PHONY: $(addsuffix -savedefconfig,$(TARGET_BOARD))
# $(addsuffix -savedefconfig,$(TARGET_BOARD)): %-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) savedefconfig BR2_DEFCONFIG=$(DEFCONFIG_DIR)/$(TARGET_BOARD)_defconfig  
# #$(DEFCONFIG_DIR)/$(TARGET_BOARD)_defconfig


.PHONY: $(addsuffix -linux-menuconfig,$(TARGET_BOARD))
$(addsuffix -linux-menuconfig,$(TARGET_BOARD)): %-linux-menuconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Linux kernel configuration.] $*")
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD)/ linux-menuconfig

.PHONY: $(addsuffix -linux-savedefconfig,$(TARGET_BOARD))
$(addsuffix -linux-savedefconfig,$(TARGET_BOARD)): %-linux-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Linux Savedefconfig]")
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) linux-update-defconfig || \
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) linux-savedefconfig

.PHONY: $(addsuffix -uboot-menuconfig,$(TARGET_BOARD))
$(addsuffix -uboot-menuconfig,$(TARGET_BOARD)): %-uboot-menuconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Bootloader configuration.] $*")
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) uboot-menuconfig

.PHONY: $(addsuffix -uboot-savedefconfig,$(TARGET_BOARD))
$(addsuffix -uboot-savedefconfig,$(TARGET_BOARD)): %-uboot-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Uboot Savedefconfig]")
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) uboot-update-defconfig || \
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) uboot-savedefconfig

.PHONY: $(addsuffix -busybox-menuconfig,$(TARGET_BOARD))
$(addsuffix -busybox-menuconfig,$(TARGET_BOARD)): %-busybox-menuconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Change the Busybox configuration.] $*")
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD)/ busybox-menuconfig

.PHONY: $(addsuffix -busybox-savedefconfig,$(TARGET_BOARD))
$(addsuffix -busybox-savedefconfig,$(TARGET_BOARD)): %-busybox-savedefconfig: $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [Busybox Savedefconfig]")
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) busybox-update-defconfig || \
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) busybox-savedefconfig

# # Change buildroot configuration for the specific board
# .PHONY: $(addsuffix -build,$(TARGET_BOARD))
# $(addsuffix -build,$(TARGET_BOARD)): %-build: $(OOSB)/build-$(TARGET_BOARD)/.config
# 	@echo "[build: $(TARGET_BOARD)]"
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD)


# $(TARGET_BOARD)-linux-menuconfig $(TARGET_BOARD)-linux-update-defconfig $(TARGET_BOARD)-busybox-menuconfig $(TARGET_BOARD)-busybox-update-config 
# $(TARGET_BOARD)-uboot-menuconfig $(TARGET_BOARD)-uboot-update-defconfig legal-info:
# 	@echo "[$@ $(PRODUCT)]"
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) PRODUCT=$(PRODUCT) PRODUCT_VERSION=$(PRODUCT_VERSION) $@


# 	@$(call MESSAGE,"[building: $(TARGET_BOARD)]")
# ifneq ($(FAKE_BUILD),true)
# 	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) $(BUILDROOT_OPTIONS) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION)
# else
# 	$(eval BOARD := $(shell echo $(TARGET_BOARD) | cut -d'_' -f2-))
# 	# Dummy build - mainly for testing CI
# 	echo -n "FAKE_BUILD - generating fake release archives..."
# 	mkdir -p build-$(TARGET_BOARD)/images
# endif

##################################################################################################################################
#
#    					BR2 Clean goals
#
##################################################################################################################################

.PHONY: $(addsuffix -clean, $(SUPPORTED_TARGETS))
$(addsuffix -clean, $(SUPPORTED_TARGETS)):
	@$(call MESSAGE,"$(TARGET_BOARD) [ clean]")
# 	@rm -rf $(OOSB)/build-$(TARGET_BOARD)

# clean-all: $(addsuffix -clean, $(SUPPORTED_TARGETS))
# $(addsuffix -clean, $(SUPPORTED_TARGETS)): %:
# 	@$(call MESSAGE,"$(TARGET_BOARD) [clean all] $@")
# # @$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD) TARGET_BOARD=$(subst -clean,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) clean

.PHONY: $(addsuffix -distclean,$(TARGET_BOARD))
$(addsuffix -distclean,$(TARGET_BOARD)): %-distclean:
	@$(call MESSAGE," $(TARGET_BOARD) [ distclean]")
# 	@$(BUILDROOT_OPTIONS) O=$(OOSB)/build-$(TARGET_BOARD)/$* distclean
# 	rm -rf $(OOSB)/build-$(TARGET_BOARD)/$*

realclean:
	-rm -fr $(OOSB) .buildroot-patched .buildroot-downloaded

# .PHONY: distclean
# distclean: clean-all
# 	@$(call MESSAGE,"$(TARGET_BOARD) [distclean]")
# 	@rm -rf $(OOSB)/buildroot-$(BUILDROOT_VERSION)
# 	@rm -f  $(OOSB)/buildroot-$(BUILDROOT_VERSION).tar.*
# 	@rm -rf .buildroot-downloaded


# .PHONY: general-reset
# general-reset:
# 	@$(call MESSAGE,"The destoyer $@")
# 	@rm -rvf $(OOSB)

##################################################################################################################################
#
#    					Caluculate Checksum Target
#
##################################################################################################################################

# .PHONY: checksum
# checksum: MD5SUMS SHA1SUMS SHA256SUMS SHA512SUMS

# .PHONY: MD5SUMS
# MD5SUMS: $(OOSB)/build-$(TARGET_BOARD)/MD5SUMS
# $(OOSB)/build-$(TARGET_BOARD)/MD5SUMS: $(TARGETS)
# 	@cd "$(OOSB)/build-$(TARGET_BOARD)" && md5sum $^ | tee $@ > /dev/null

# .PHONY: SHA1SUMS
# SHA1SUMS: $(OOSB)/build-$(TARGET_BOARD)/SHA1SUMS
# $(OOSB)/build-$(TARGET_BOARD)/SHA1SUMS: $(TARGETS)
# 	@cd "$(OOSB)/build-$(TARGET_BOARD)" && sha1sum $^ | tee $@ > /dev/null

# .PHONY: SHA256SUMS
# SHA256SUMS: $(OOSB)/build-$(TARGET_BOARD)/SHA256SUMS
# $(OOSB)/build-$(TARGET_BOARD)/SHA256SUMS: $(TARGETS)
# 	@cd "$(OOSB)/build-$(TARGET_BOARD)" && sha256sum $^ | tee $@ > /dev/null

# .PHONY: SHA512SUMS
# SHA512SUMS: $(OOSB)/build-$(TARGET_BOARD)/SHA512SUMS
# $(OOSB)/build-$(TARGET_BOARD)/SHA512SUMS: $(TARGETS)
# 	@cd "$(OOSB)/build-$(TARGET_BOARD)" && sha512sum $^ | tee $@ > /dev/null


##################################################################################################################################
#
#    					Build
#
##################################################################################################################################
.PHONY: $(addsuffix -compile,$(TARGET_BOARD))
$(addsuffix -compile,$(TARGET_BOARD)): | $(OOSB)/buildroot-$(BUILDROOT_VERSION) $(OOSB)/build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"$(TARGET_BOARD) [ Compiling]")

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
#    					test
#
##################################################################################################################################

##################################################################################################################################
#
#    					inetgration test
#
##################################################################################################################################

##################################################################################################################################
#
#    					Upload artifact to target 
#
##################################################################################################################################
# burn-upgrade:
# 	@scp -P 23060 $(OOSB)/build-$(TARGET_BOARD)/images user@host:/path/to/tftp/folder


##################################################################################################################################
#
#    CFSOS Packages
#
##################################################################################################################################

################################################################################
# Caluculate Checksum Target
################################################################################

.PHONY:  $(addsuffix -checksum,$(TARGET_BOARD))
$(addsuffix -checksum,$(TARGET_BOARD)): $(addsuffix -package,$(TARGET_BOARD)) $(addsuffix -MD5SUMS,$(TARGET_BOARD)) $(addsuffix -SHA1SUMS,$(TARGET_BOARD)) $(addsuffix -SHA256SUMS,$(TARGET_BOARD)) $(addsuffix -SHA512SUMS,$(TARGET_BOARD)) 

.PHONY: $(addsuffix -MD5SUMS,$(TARGET_BOARD))
$(addsuffix -MD5SUMS,$(TARGET_BOARD)): $(DIST_DIR)/MD5SUMS
$(DIST_DIR)/MD5SUMS: $(TARGETS)
	@$(call MESSAGE,"$(TARGET_BOARD) [ MD5SUMS computing]")
# @cd $(OOSB)/build-$(TARGET_BOARD)/images && md5sum $^ | tee $@ > /dev/null

.PHONY: $(addsuffix -SHA1SUMS,$(TARGET_BOARD))
$(addsuffix -SHA1SUMS,$(TARGET_BOARD)): $(DIST_DIR)/SHA1SUMS
$(DIST_DIR)/SHA1SUMS: $(TARGETS)
	@$(call MESSAGE,"$(TARGET_BOARD) [ SHA1SUMS computing]")
#	@cd $(OOSB)/build-$(TARGET_BOARD)/images && sha1sum $^ | tee $@ > /dev/null

.PHONY: $(addsuffix -SHA256SUMS,$(TARGET_BOARD))
$(addsuffix -SHA256SUMS,$(TARGET_BOARD)): $(DIST_DIR)/SHA256SUMS
$(DIST_DIR)/SHA256SUMS: $(TARGETS)
	@$(call MESSAGE,"$(TARGET_BOARD) [ SHA256SUMS computing]")
#	@cd $(OOSB)/build-$(TARGET_BOARD)/images && sha256sum $^ | tee $@ > /dev/null

.PHONY: $(addsuffix -SHA512SUMS,$(TARGET_BOARD))
$(addsuffix -SHA512SUMS,$(TARGET_BOARD)): $(DIST_DIR)/SHA512SUMS
$(DIST_DIR)/SHA512SUMS: $(TARGETS)
	@$(call MESSAGE,"$(TARGET_BOARD) [ SHA512SUMS computing]")
#	@cd $(OOSB)/build-$(TARGET_BOARD)/images && sha512sum $^ | tee $@ > /dev/null

################################################################################
# Build Infomation Target
################################################################################

.PHONY: $(addsuffix -show,$(TARGET_BOARD))
$(addsuffix -show,$(TARGET_BOARD)): $(addsuffix -MD5SUMS,$(TARGET_BOARD)) $(addsuffix -SHA1SUMS,$(TARGET_BOARD)) $(addsuffix -SHA256SUMS,$(TARGET_BOARD)) $(addsuffix -SHA512SUMS,$(TARGET_BOARD))
	@echo "MD5SUMS"
	@cat $(DIST_DIR)/MD5SUMS
	@echo
	@echo "SHA1SUMS"
	@cat $(DIST_DIR)/SHA1SUMS
	@echo
	@echo "SHA256SUMS"
	@cat $(DIST_DIR)/SHA256SUMS
	@echo
	@echo "SHA512SUMS"
	@cat $(DIST_DIR)/SHA512SUMS








==================================================================================================================================================================


buildroot-$(BUILDROOT_VERSION).tar.gz:
ifneq ($(BUILDROOT_LATEST),"")
	@if [ ! -d buildroot-$(BUILDROOT_VERSION) ]; then git clone --depth=1 https://github.com/buildroot/buildroot buildroot-$(BUILDROOT_VERSION); fi
else
	@$(call MESSAGE,"[downloading buildroot-$(BUILDROOT_VERSION).tar.gz]")
	wget https://github.com/buildroot/buildroot/archive/refs/tags/$(BUILDROOT_VERSION).tar.gz -O buildroot-$(BUILDROOT_VERSION).tar.gz
	echo "$(BUILDROOT_SHA256)  buildroot-$(BUILDROOT_VERSION).tar.gz" >buildroot-$(BUILDROOT_VERSION).tar.gz.sign
	shasum -a 256 -c buildroot-$(BUILDROOT_VERSION).tar.gz.sign
endif

# if [ ! -d $(BUILD_DIR)/buildroot ]; then \
# 	mkdir -p $(BUILD_DIR); \
# 	git clone --depth=1 --branch=$(BUILDROOT_BRANCH) https://github.com/buildroot/buildroot $(BUILD_DIR)/buildroot; \
# fi;



download: buildroot-$(BUILDROOT_VERSION)
	@test -e download || mkdir -pv download


.PHONY: xconfig
xconfig: buildroot-$(BUILDROOT_VERSION) build-$(TARGET_BOARD)/.config
	@echo
	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) $(BUILDROOT_OPTIONS) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) xconfig

build-$(TARGET_BOARD)/.config: | build-$(TARGET_BOARD)
	@echo
	@$(call MESSAGE,"[Setup $(TARGET_BOARD) config $@]")
	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) $(BUILDROOT_OPTIONS) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) $(TARGET_BOARD)_defconfig

# 	@$(call MESSAGE,"[building: $(TARGET_BOARD)]")
# ifneq ($(FAKE_BUILD),true)
# 	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) $(BUILDROOT_OPTIONS) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION)
# else
# 	$(eval BOARD := $(shell echo $(TARGET_BOARD) | cut -d'_' -f2-))
# 	# Dummy build - mainly for testing CI
# 	echo -n "FAKE_BUILD - generating fake release archives..."
# 	mkdir -p build-$(TARGET_BOARD)/images
# endif

# build-all: $(SUPPORTED_TARGETS)
# $(SUPPORTED_TARGETS): %:
# 	@$(call MESSAGE,"[Building build: $@]")
# 	@$(MAKE) TARGET_BOARD=$@ PRODUCT_VERSION=$(PRODUCT_VERSION) build

# sign-release:
# 	gpg --passphrase-file <(echo ${ENCRYPT_PASSWORD}) --batch --output export_cfg.gpg -c export_presets.cfg
#   find . -name '*.zip' -exec gpg -u YOU@exemple.org --armor --output {}.asc --detach-sign {} \;
# 	find . -name '*.license' -exec gpg -u YOU@apache.org --armor --output {}.asc --detach-sign {} \;
#   @$(call MESSAGE,"[Verify $(TARGET_BOARD)] Signatures")
#   find . -name '*.sha512' -execdir sha512sum --check '{}' \;
#   @$(call MESSAGE,"[Check the  $(TARGET_BOARD)] SHA512 checksums")

# .PHONY: checksum
# checksum: ## Generate checksums
# 	for f in $(shell pwd)/build-$(TARGET_BOARD)/images/zImage \
# 		$(shell pwd)/build-$(TARGET_BOARD)/images/u-boot-with-spl \
# 		 $(shell pwd)/build-$(TARGET_BOARD)/images/$(TARGET_BOARD).dtb; do \
# 		if [ -f "$${f}" ]; then \
# 			openssl sha256 "$${f}" | awk '{print $$2}' > "$${f}.sha256" ; \
# 		fi ; \
# 	done
################################################################################
# Caluculate Checksum Target
################################################################################

.PHONY: checksum
checksum: MD5SUMS SHA1SUMS SHA256SUMS SHA512SUMS

.PHONY: MD5SUMS
MD5SUMS: $(DIST_DIR)/MD5SUMS
$(DIST_DIR)/MD5SUMS: $(TARGETS)
	@cd "$(DIST_DIR)" && md5sum $^ | tee $@ > /dev/null

.PHONY: SHA1SUMS
SHA1SUMS: $(DIST_DIR)/SHA1SUMS
$(DIST_DIR)/SHA1SUMS: $(TARGETS)
	@cd "$(DIST_DIR)" && sha1sum $^ | tee $@ > /dev/null

.PHONY: SHA256SUMS
SHA256SUMS: $(DIST_DIR)/SHA256SUMS
$(DIST_DIR)/SHA256SUMS: $(TARGETS)
	@cd "$(DIST_DIR)" && sha256sum $^ | tee $@ > /dev/null

.PHONY: SHA512SUMS
SHA512SUMS: $(DIST_DIR)/SHA512SUMS
$(DIST_DIR)/SHA512SUMS: $(TARGETS)
	@cd "$(DIST_DIR)" && sha512sum $^ | tee $@ > /dev/null

################################################################################
# Build Infomation Target
################################################################################

.PHONY: show
show: MD5SUMS SHA1SUMS SHA256SUMS SHA512SUMS
	@echo "MD5SUMS"
	@cat $(DIST_DIR)/MD5SUMS
	@echo
	@echo "SHA1SUMS"
	@cat $(DIST_DIR)/SHA1SUMS
	@echo
	@echo "SHA256SUMS"
	@cat $(DIST_DIR)/SHA256SUMS
	@echo
	@echo "SHA512SUMS"
	@cat $(DIST_DIR)/SHA512SUMS





