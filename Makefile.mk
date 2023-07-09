.DEFAULT_GOAL:=help

include br-external.conf

ifneq ($(TARGET_BOARD),)
	SUPPORTED_TARGETS:=$(TARGET_BOARD)
else
	TARGET_BOARD:=$(firstword $(SUPPORTED_TARGETS))
endif

PARALLEL_JOBS := $(shell getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
ifneq ($(PARALLEL_JOBS),1)
	PARALLEL_OPTS = -j$(PARALLEL_JOBS) -Orecurse
else
	PARALLEL_OPTS =
endif


.NOTPARALLEL: $(SUPPORTED_TARGETS) $(addsuffix -release, $(SUPPORTED_TARGETS)) $(addsuffix -clean, $(SUPPORTED_TARGETS)) build-all clean-all release-all
#.PHONY: all build release clean cleanall distclean help updatePkg



release-all: $(addsuffix -release, $(SUPPORTED_TARGETS))
$(addsuffix -release, $(SUPPORTED_TARGETS)): %:
	@$(MAKE) TARGET_BOARD=$(subst -release,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) release

.PHONY:release
release: build
	@$(call MESSAGE,"[creating release: $(TARGET_BOARD)]")
	$(eval BOARD_DIR := $(BROOT_EXTERNAL)/board/$(shell echo $(TARGET_BOARD) | cut -d'_' -f2))
	if [ -x $(BOARD_DIR)/post-release.sh ]; then $(BOARD_DIR)/post-release.sh $(BOARD_DIR) ${TARGET_BOARD} ${PRODUCT_VERSION}; fi

check-all: $(addsuffix -check, $(SUPPORTED_TARGETS))
$(addsuffix -check, $(SUPPORTED_TARGETS)): %:
	@$(MAKE) TARGET_BOARD=$(subst -check,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) check

check: buildroot-$(BUILDROOT_VERSION) build-$(TARGET_BOARD)/.config
	@$(call MESSAGE,"[checking: $(TARGET_BOARD)]")
	$(eval BOARD_DIR := $(BROOT_EXTERNAL)/board/$(shell echo $(TARGET_BOARD) | cut -d'_' -f2))
	@$(call MESSAGE,"[checking status: $(BROOT_EXTERNAL)]")
	buildroot-$(BUILDROOT_VERSION)/utils/check-package --exclude PackageHeader --br2-external $(BROOT_EXTERNAL)/package/*/*



.PHONY: menuconfig
menuconfig: buildroot-$(BUILDROOT_VERSION) build-$(TARGET_BOARD)/.config
	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) -C "$(PWD)/buildroot-$(BUILDROOT_VERSION)" BR2_EXTERNAL=$(PWD)/$(BROOT_EXTERNAL) BR2_DL_DIR=$(DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) menuconfig

.PHONY: xconfig
xconfig: buildroot-$(BUILDROOT_VERSION) build-$(TARGET_BOARD)/.config
	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) -C "$(PWD)/buildroot-$(BUILDROOT_VERSION)" BR2_EXTERNAL=$(PWD)/$(BROOT_EXTERNAL) BR2_DL_DIR=$(DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) xconfig

.PHONY: savedefconfig
savedefconfig: buildroot-$(BUILDROOT_VERSION) build-$(TARGET_BOARD)
	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) -C "$(PWD)/buildroot-$(BUILDROOT_VERSION)" BR2_EXTERNAL=$(PWD)/$(BROOT_EXTERNAL) BR2_DL_DIR=$(DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) savedefconfig BR2_DEFCONFIG=../$(DEFCONFIG_DIR)/$(TARGET_BOARD)_defconfig

.PHONY: toolchain
toolchain: buildroot-$(BUILDROOT_VERSION) build-$(TARGET_BOARD)/.config
	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) -C "$(PWD)/buildroot-$(BUILDROOT_VERSION)" BR2_EXTERNAL=$(PWD)/$(BROOT_EXTERNAL) BR2_DL_DIR=$(DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) toolchain


linux-menuconfig linux-update-defconfig busybox-menuconfig busybox-update-config uboot-menuconfig uboot-update-defconfig legal-info:
	@$(call MESSAGE,"[$@ $(TARGET_BOARD)]")
	@$(MAKE) -C build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) $@


debug-build-$(TARGET_BOARD):
	@[ -f build-$(TARGET_BOARD)/staging/.gdbinit ]    || cp $(CURDIR)/.gdbinit $(O)/staging/.gdbinit
	@[ -f build-$(TARGET_BOARD)/staging/.gdbinit.py ] || cp $(CURDIR)/.gdbinit.py $(O)/staging/.gdbinit.py
	@(cd build-$(TARGET_BOARD)/staging/ && gdb-multiarch)


#  Create a fallback target (%) to forward all unknown target calls to the build Makefile.
linux-menuconfig linux-update-defconfig \
busybox-menuconfig busybox-update-config \
uboot-menuconfig uboot-update-defconfig \
graph-build graph-depends graph-size\
manual list-defconfigs legal-info:
	@$(call MESSAGE,"make $@ to $(TARGET_BOARD)")
	@$(MAKE) -C build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) BR2_EXTERNAL=$(PWD)/$(BUILDROOT_EXTERNAL) BR2_DL_DIR=$(DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) $@


.PHONY: help
help:
	@echo "\e[7mBuild Environment\e[0m"
	@echo
	@echo "Usage:"
	@echo "  $(MAKE) <product>: build+create image for selected product"
	@echo "  $(MAKE) build-all: run build for all supported products"
	@echo
	@echo "  $(MAKE) <product>-release: build+create release archive for product"
	@echo "  $(MAKE) release-all: build+create release archive for all supported products"
	@echo
	@echo "  $(MAKE) <product>-check: run ci consistency check for product"
	@echo "  $(MAKE) check-all: run ci consistency check all supported platforms"
	@echo
	@echo "  $(MAKE) <product>-clean: remove build directory for product"
	@echo "  $(MAKE) clean-all: remove build directories for all supported platforms"
	@echo
	@echo "  $(MAKE) distclean: clean everything (all build dirs and buildroot sources)"
	@echo
	@echo "  $(MAKE) TARGET_BOARD=<product> \e[7mmenuconfig\e[0m: change buildroot config options"
	@echo "  $(MAKE) TARGET_BOARD=<product> \e[7msavedefconfig\e[0m: update buildroot defconfig file"
	@echo "  $(MAKE) TARGET_BOARD=<product> \e[7mlinux-menuconfig\e[0m: change linux kernel config option"
	@echo "  $(MAKE) TARGET_BOARD=<product> \e[7mlinux-update-defconfig\e[0m: update linux kernel defconfig file"
	@echo "  $(MAKE) TARGET_BOARD=<product> \e[7mbusybox-menuconfig\e[0m: change busybox config options"
	@echo "  $(MAKE) TARGET_BOARD=<product> \e[7mbusybox-update-config\e[0m: update busybox defconfig file"
	@echo "  $(MAKE) TARGET_BOARD=<product> \e[7muboot-menuconfig\e[0m: change u-boot config options"
	@echo "  $(MAKE) TARGET_BOARD=<product> \e[7muboot-update-defconfig\e[0m: update u-boot defconfig file"
	@echo
	@echo "  $(MAKE) TARGET_BOARD=<product> legal-info: update legal information file"
	@echo
	@echo "Supported targets:"
	@$(foreach defconfig,$(SUPPORTED_TARGETS), \
		echo '   	$(defconfig)+'; \
	)	
	@ # Match all targets which have preceding `## ` comments.
	@ awk '/^## / { sub(/^##/, "", $$0) ; desc = desc $$0 ; next } \
		 /^[[:alpha:]][[:alnum:]_-]+:/ && desc { print "  " $$1 desc } \
		 { desc = "" }' $(MAKEFILE_LIST) | sort | column -s: -t
		 

		 
		 
