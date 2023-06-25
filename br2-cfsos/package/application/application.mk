################################################################################
#
# APPLICATION
#
################################################################################

APPLICATION_VERSION = 1.0
APPLICATION_SITE = $(BR2_EXTERNAL_EXTERNAL_PACKAGES_PATH)/package/application
APPLICATION_SITE_METHOD = local
APPLICATION_LICENSE = GPL-2.0
APPLICATION_LICENSE_FILES = COPYING

define APPLICATION_BUILD_CMDS
    $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) all
endef

define APPLICATION_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/application $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
