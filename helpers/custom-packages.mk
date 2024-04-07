PROJECT_PACKAGES 		:= helloworld i2c gpio_pulse_counter
# PROJECT_PACKAGES 		:= helloworld
#                     					clean-for-rebuild					
#                     					dirclean 							
SPECIFIC_PACKAGE_GOALS 	:= $(foreach defconfig,$(SUPPORTED_TARGETS),		\
    							$(foreach package,$(PROJECT_PACKAGES),		\
                 					$(addprefix $(defconfig)-$(package)-,	\
										rebuild 							\
										show-info							\
										show-version							\
                 					) 										\
             					) 											\
         					)
word-dash = $(word $2,$(subst -, ,$1))

$(foreach goal,$(SPECIFIC_PACKAGE_GOALS),$(goal)):
	$(Q)$(call MESSAGE,"  [Executing $(word 2,$(subst $(call word-dash,$@,2), ,$@)) target on $(call UC, $(call word-dash,$@,1))'s $(call word-dash,$@,2) package ]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc/$(call word-dash,$@,1) O=$(BLRT_OOSB)/$(call word-dash,$@,1)-build-artifacts $(patsubst $(firstword $(SUPPORTED_TARGETS))-%,%,$@)



$(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-package-clean): %-package-clean: $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-clean-for-rebuild))
$(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-clean-for-rebuild)):
	$(Q)$(call MESSAGE,"  [Executing clean target on $(call UC, $(call word-dash,$@,1))'s package $(call word-dash,$@,2) ]")
	$(Q)echo $(MAKE) $(BLRT_MAKEARGS) BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc/$(call word-dash,$@,1) O=$(BLRT_OOSB)/$(call word-dash,$@,1)-build-artifacts $(patsubst $(firstword $(SUPPORTED_TARGETS))-%,%,$@)

$(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-package-dirclean): %-package-dirclean: $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-dirclean))
$(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-dirclean)):
	$(Q)$(call MESSAGE,"  [Executing clean target on $(call UC, $(call word-dash,$@,1))'s package $(call word-dash,$@,2) ]")
	$(Q)echo $(MAKE) $(BLRT_MAKEARGS) BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc/$(call word-dash,$@,1) O=$(BLRT_OOSB)/$(call word-dash,$@,1)-build-artifacts $(patsubst $(firstword $(SUPPORTED_TARGETS))-%,%,$@)


# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-package-clean): %-package-clean: $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-clean))
# 	$(Q)$(call MESSAGE,"[ Cleaning all $* packages inside $(BLRT_OOSB)/$*-build-artifacts]")
# define CLEAN_RULE
# $(1):
# 	$(Q)$(call MESSAGE,"  [Executing clean target on $(call UC, $(call word-dash,$$@,1))'s package $(call word-dash,$$@,2) ]")
# 	$(Q)echo $(MAKE) $(BLRT_MAKEARGS) BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc/$(call word-dash,$$@,1) O=$(BLRT_OOSB)/$(call word-dash,$$@,1)-build-artifacts $(patsubst $(firstword $(SUPPORTED_TARGETS))-%,%,$$@)
# endef
# $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(eval $(call CLEAN_RULE,$(defconfig)-$(package)-clean))))



# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-package-dirclean): %-package-dirclean: $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-dirclean))
# 	$(Q)$(call MESSAGE,"[ Wiping all $* packages artifacts inside $(BLRT_OOSB)/$*-build-artifacts]")
# define DIR_CLEAN_RULE
# $(1):
# 	$(Q)$(call MESSAGE,"  [Wiping artifacts on $(call UC, $(call word-dash,$$@,1))'s package $(call word-dash,$$@,2) ]")
# 	$(Q)echo $(MAKE) $(BLRT_MAKEARGS) BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc/$(call word-dash,$$@,1) O=$(BLRT_OOSB)/$(call word-dash,$$@,1)-build-artifacts $(patsubst $(firstword $(SUPPORTED_TARGETS))-%,%,$$@)
# endef
# $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(eval $(call DIR_CLEAN_RULE,$(defconfig)-$(package)-dirclean))))



# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-package-wiped): %-package-wiped: $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-clean))
# 	$(Q)$(call MESSAGE,"[ Cleaned all $* packages inside $(BLRT_OOSB)/$*-build-artifacts]")

# clean_package: $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-clean))
# define CLEAN_RULE
# $(1):
# 	$(Q)$(call MESSAGE,"  [Executing clean target on $(call UC, $(call word-dash,$$@,1))'s package $(call word-dash,$$@,2) ]")
# 	$(Q)echo $(MAKE) $(BLRT_MAKEARGS) BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc/$(call word-dash,$$@,1) O=$(BLRT_OOSB)/$(call word-dash,$$@,1)-build-artifacts $(patsubst $(firstword $(SUPPORTED_TARGETS))-%,%,$$@)
# endef
# $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(eval $(call CLEAN_RULE,$(defconfig)-$(package)-clean))))




# clean_package: $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-clean))
# $(foreach defconfig,$(SUPPORTED_TARGETS),$(foreach package,$(PROJECT_PACKAGES),$(defconfig)-$(package)-clean)):
# 	$(Q)$(call MESSAGE,"  [Executing clean target on $(call UC, $(call word-dash,$@,1))'s package $(call word-dash,$@,2) ]")
# 	$(Q)echo $(MAKE) $(BLRT_MAKEARGS) BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc/$(call word-dash,$@,1) O=$(BLRT_OOSB)/$(call word-dash,$@,1)-build-artifacts $(patsubst $(firstword $(SUPPORTED_TARGETS))-%,%,$@)

# $(Q)$(call MESSAGE,"  [Rebuilding $(call UC, $(word 1,$(subst -, ,$(subst $*-,,$@)))) $* configuration change!]")
# $(Q)$(call MESSAGE,"  [Rebuilding $@  $*  - $(call word-dash,$@,1)- $(call word-dash,$@,2) ]")

# define br2_package_rebuild_rdeps
# 	for RDEP in `$(MAKE) -s -C buildroot $(BUILDROOT_ARGS) $(1)-show-rdepends`; do \
# 		echo $$RDEP; \
# 		$(MAKE) -C buildroot $(BUILDROOT_ARGS) $$RDEP-dirclean; \
# 		$(MAKE) -C buildroot $(BUILDROOT_ARGS) $$RDEP-rebuild; \
# 	done
# endef



# rebuild-gps:
# 	$(MAKE) -C buildroot $(BUILDROOT_ARGS) gps-dirclean
# 	$(MAKE) -C buildroot $(BUILDROOT_ARGS) gps-rebuild

# rebuild-gps-rdeps:
# 	$(call br2dfb2_rebuibr2_package_rebuild_rdepsld_rdeps,gps)



# helloworld-install
# helloworld-install-host
# helloworld-install-images
# helloworld-install-staging
# helloworld-install-target
# helloworld-legal-info
# helloworld-legal-source
# helloworld-patch
# helloworld-rebuild
# helloworld-reconfigure
# helloworld                               helloworld-reinstall
# helloworld-all-external-deps             helloworld-rsync
# helloworld-all-legal-info                helloworld-show-build-order
# helloworld-all-source                    helloworld-show-depends
# helloworld-build                         helloworld-show-info
# helloworld-clean-for-rebuild             helloworld-show-rdepends
# helloworld-clean-for-reconfigure         helloworld-show-recursive-depends
# helloworld-clean-for-reinstall           helloworld-show-recursive-rdepends
# helloworld-configure                     helloworld-show-version
# helloworld-depends                       helloworld-source
# helloworld-dirclean
# helloworld-external-deps                 
# helloworld-extract                       
# helloworld-graph-depends 