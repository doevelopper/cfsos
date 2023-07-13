################################################################################
#
# sord
#
################################################################################

CRITERION_VERSION = v2.4.2
CRITERION_SITE = $(call github,Snaipe,Criterion,$(CRITERION_VERSION))
CRITERION_SOURCE = $(CRITERION_VERSION).tar.gz
CRITERION_LICENSE = MIT
CRITERION_LICENSE_FILES = LICENSE
CRITERION_DEPENDENCIES = host-pkgconf
CRITERION_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_LIBFFI),y)
CRITERION_DEPENDENCIES += libffi
endif

CRITERION_CONF_OPTS += 

$(eval $(meson-package))
