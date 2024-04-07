##############################################
#
# Hello world
#
##############################################

GPIO_PULSE_COUNTER_VERSION = 1.0
GPIO_PULSE_COUNTER_SITE = $(BR2_EXTERNAL_CFSOS_PATH)/package/drivers/kernel-space/gpio_pulse_counter/src
GPIO_PULSE_COUNTER_SITE_METHOD = local

define GPIO_PULSE_COUNTER_BUILD_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules
endef

define GPIO_PULSE_COUNTER_INSTALL_TARGET_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules_install
endef

define GPIO_PULSE_COUNTER_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_MODULE_UNLOAD)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
