##############################################
#
# Hello world
#
##############################################

GPIO_I2C_VERSION = 1.0
GPIO_I2C_SITE = $(BR2_EXTERNAL_CFSOS_PATH)/package/drivers/kernel-space/gpio_i2c/src
GPIO_I2C_SITE_METHOD = local

define GPIO_I2C_BUILD_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules
endef

define GPIO_I2C_INSTALL_TARGET_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules_install
endef

define GPIO_I2C_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_MODULE_UNLOAD)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
