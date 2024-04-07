##############################################
#
# 4fsk-app
#
##############################################

4FSK_APP_VERSION = 1.0
4FSK_APP_SITE = $(BR2_EXTERNAL_CFSOS_PATH)/package/drivers/user-space/4fsk-app/src
4FSK_APP_SITE_METHOD = local

define 4FSK_APP_BUILD_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules
endef

define 4FSK_APP_INSTALL_TARGET_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules_install
endef

define 4FSK_APP_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_MODULE_UNLOAD)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
