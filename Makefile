BUILDROOT_VERSION=2023.05
BUILDROOT_SHA256=422e17a5851d85c47628ff0cd964318b5c3405cc9b4b3c727d872db7ece6779a
BROOT_EXTERNAL=br2-cfsos
DEFCONFIG_DIR=$(BROOT_EXTERNAL)/configs
DHS_VERSION=$(shell grep "DHS_VERSION =" $(BROOT_EXTERNAL)/package/dhs/dhs.mk | cut -d' ' -f3 | cut -d'-' -f1)
DATE=$(shell date +%Y%m%d)
TARGET_BOARD=
PRODUCT_VERSION=${DHS_VERSION}.${DATE}
SUPPORTED_TARGETS:=$(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))))
PWD := $(shell pwd)
DL_DIR := $(if $(BR2_DL_DIR),$(BR2_DL_DIR),$(PWD)/../download)
BR2_CCACHE_DIR="${HOME}/.buildroot-ccache"
BR2_JLEVEL=$(shell nproc)
BR=$(MAKE) -C "$(PWD)/buildroot-$(BUILDROOT_VERSION)"
BUILD_DIR={PWD}/output
BRMAKE = buildroot-$(BUILDROOT_VERSION)/utils/brmake -C buildroot-$(BUILDROOT_VERSION)

ifneq ($(TARGET_BOARD),)
	SUPPORTED_TARGETS:=$(TARGET_BOARD)
else
	TARGET_BOARD:=$(firstword $(SUPPORTED_TARGETS))
endif

.NOTPARALLEL: $(SUPPORTED_TARGETS) $(addsuffix -release, $(SUPPORTED_TARGETS)) $(addsuffix -clean, $(SUPPORTED_TARGETS)) build-all clean-all release-all
.PHONY: all build release clean cleanall distclean help updatePkg

all: help

buildroot-$(BUILDROOT_VERSION).tar.gz:
	@echo "[downloading buildroot-$(BUILDROOT_VERSION).tar.gz]"
	wget https://github.com/buildroot/buildroot/archive/refs/tags/$(BUILDROOT_VERSION).tar.gz -O buildroot-$(BUILDROOT_VERSION).tar.gz
	echo "$(BUILDROOT_SHA256)  buildroot-$(BUILDROOT_VERSION).tar.gz" >buildroot-$(BUILDROOT_VERSION).tar.gz.sign
	shasum -a 256 -c buildroot-$(BUILDROOT_VERSION).tar.gz.sign

buildroot-$(BUILDROOT_VERSION): | buildroot-$(BUILDROOT_VERSION).tar.gz
	@echo "[patching buildroot-$(BUILDROOT_VERSION)]"
	if [ ! -d $@ ]; then tar xf buildroot-$(BUILDROOT_VERSION).tar.gz; for p in $(sort $(wildcard buildroot-patches/*.patch)); do echo "\nApplying $${p}"; patch -d buildroot-$(BUILDROOT_VERSION) --remove-empty-files -p1 < $${p} || exit 127; [ ! -x $${p%.*}.sh ] || $${p%.*}.sh buildroot-$(BUILDROOT_VERSION); done; fi

build-$(TARGET_BOARD): | buildroot-$(BUILDROOT_VERSION) download
	mkdir build-$(TARGET_BOARD)

download: buildroot-$(BUILDROOT_VERSION)
	test -e download || mkdir download

build-$(TARGET_BOARD)/.config: | build-$(TARGET_BOARD)
	@echo "[config $@]"
	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) -C "$(PWD)/buildroot-$(BUILDROOT_VERSION)" BR2_EXTERNAL=$(PWD)/$(BROOT_EXTERNAL) BR2_DL_DIR=$(DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) $(TARGET_BOARD)_defconfig

build-all: $(SUPPORTED_TARGETS)
$(SUPPORTED_TARGETS): %:
	@echo "[build: $@]"
	@$(MAKE) TARGET_BOARD=$@ PRODUCT_VERSION=$(PRODUCT_VERSION) build

build: | buildroot-$(BUILDROOT_VERSION) build-$(TARGET_BOARD)/.config
	@echo "[build: $(TARGET_BOARD)]"
ifneq ($(FAKE_BUILD),true)
	cd $(shell pwd)/build-$(TARGET_BOARD) && $(MAKE) O=$(shell pwd)/build-$(TARGET_BOARD) -C "$(PWD)/buildroot-$(BUILDROOT_VERSION)" BR2_EXTERNAL=$(PWD)/$(BROOT_EXTERNAL) BR2_DL_DIR=$(DL_DIR) BR2_CCACHE_DIR=$(BR2_CCACHE_DIR) BR2_JLEVEL=$(BR2_JLEVEL) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION)
else
	$(eval BOARD := $(shell echo $(TARGET_BOARD) | cut -d'_' -f2-))
	# Dummy build - mainly for testing CI
	echo -n "FAKE_BUILD - generating fake release archives..."
	mkdir -p build-$(TARGET_BOARD)/images
endif

release-all: $(addsuffix -release, $(SUPPORTED_TARGETS))
$(addsuffix -release, $(SUPPORTED_TARGETS)): %:
	@$(MAKE) TARGET_BOARD=$(subst -release,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) release

release: build
	@echo "[creating release: $(TARGET_BOARD)]"
	$(eval BOARD_DIR := $(BROOT_EXTERNAL)/board/$(shell echo $(TARGET_BOARD) | cut -d'_' -f2))
	if [ -x $(BOARD_DIR)/post-release.sh ]; then $(BOARD_DIR)/post-release.sh $(BOARD_DIR) ${TARGET_BOARD} ${PRODUCT_VERSION}; fi

check-all: $(addsuffix -check, $(SUPPORTED_TARGETS))
$(addsuffix -check, $(SUPPORTED_TARGETS)): %:
	@$(MAKE) TARGET_BOARD=$(subst -check,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) check

check: buildroot-$(BUILDROOT_VERSION) build-$(TARGET_BOARD)/.config
	@echo "[checking: $(TARGET_BOARD)]"
	$(eval BOARD_DIR := $(BROOT_EXTERNAL)/board/$(shell echo $(TARGET_BOARD) | cut -d'_' -f2))
	@echo "[checking status: $(BROOT_EXTERNAL)]"
	buildroot-$(BUILDROOT_VERSION)/utils/check-package --exclude PackageHeader --br2-external $(BROOT_EXTERNAL)/package/*/*

clean-all: $(addsuffix -clean, $(SUPPORTED_TARGETS))
$(addsuffix -clean, $(SUPPORTED_TARGETS)): %:
	@$(MAKE) TARGET_BOARD=$(subst -clean,,$@) PRODUCT_VERSION=$(PRODUCT_VERSION) clean

clean:
	@echo "[clean $(TARGET_BOARD)]"
	@rm -rf build-$(TARGET_BOARD)

distclean: clean-all
	@echo "[distclean]"
	@rm -rf buildroot-$(BUILDROOT_VERSION)
	@rm -f buildroot-$(BUILDROOT_VERSION).tar.*
	@rm -rf download

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
	@echo "[$@ $(TARGET_BOARD)]"
	@$(MAKE) -C build-$(TARGET_BOARD) TARGET_BOARD=$(TARGET_BOARD) PRODUCT_VERSION=$(PRODUCT_VERSION) $@

help:
	@echo "HomeMatic/CCU Build Environment"
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
	@echo "  $(MAKE) TARGET_BOARD=<product> menuconfig: change buildroot config options"
	@echo "  $(MAKE) TARGET_BOARD=<product> savedefconfig: update buildroot defconfig file"
	@echo "  $(MAKE) TARGET_BOARD=<product> linux-menuconfig: change linux kernel config option"
	@echo "  $(MAKE) TARGET_BOARD=<product> linux-update-defconfig: update linux kernel defconfig file"
	@echo "  $(MAKE) TARGET_BOARD=<product> busybox-menuconfig: change busybox config options"
	@echo "  $(MAKE) TARGET_BOARD=<product> busybox-update-config: update busybox defconfig file"
	@echo "  $(MAKE) TARGET_BOARD=<product> uboot-menuconfig: change u-boot config options"
	@echo "  $(MAKE) TARGET_BOARD=<product> uboot-update-defconfig: update u-boot defconfig file"
	@echo
	@echo "  $(MAKE) TARGET_BOARD=<product> legal-info: update legal information file"
	@echo
	@echo "Supported products: $(SUPPORTED_TARGETS)"
