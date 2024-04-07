##############################################
#
# 4fsk
##############################################

4FSK_VERSION = 1.0
4FSK_SITE = $(BR2_EXTERNAL_CFSOS_PATH)/package/drivers/kernel-space/4fsk/src
4FSK_SITE_METHOD = local

define 4FSK_BUILD_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules
endef

define 4FSK_INSTALL_TARGET_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules_install
endef

define 4FSK_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_MODULE_UNLOAD)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
