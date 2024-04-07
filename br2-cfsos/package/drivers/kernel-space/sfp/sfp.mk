################################################################################
#
# SFP kernel module
#
################################################################################

SFP_VERSION = 1.0
SFP_SITE = $(BR2_EXTERNAL_CFSOS_PATH)/package/drivers/kernel-space/sfp
SFP_SITE_METHOD = local
SFP_LICENSE = GPL-2.0
SFP_LICENSE_FILES = COPYING
SFP_DEPENDENCIES = host-dtc

define SFP_BUILD_CMDS
	for dts in $(@D)/*.dts; do \
		$(HOST_DIR)/bin/dtc -@ -I dts -O dtb -W no-unit_address_vs_reg -o $${dts%.dts}.dtbo $${dts}; \
	done
endef

define SFP_INSTALL_IMAGES_CMDS
	for dtbo in $(@D)/*.dtbo; do \
		$(INSTALL) -D -m 0644 $${dtbo} $(BINARIES_DIR)/; \
	done
endef

$(eval $(kernel-module))
$(eval $(generic-package))
