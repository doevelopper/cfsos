BASE 				?= $(CERTS_DIR)/rauc/openssl-ca
RAUC_DIR 			?= $(CERTS_DIR)/rauc
ORG 				?= ACME SYSTEM TECHNOLOGIES
CA 					?= Unmanned Systems RAUC CA
OPENSSL_CONF 		?= $(CERTS_DIR)/rauc/openssl.cnf
CA_PASSPHRASE_FILE 	?= $(CERTS_DIR)/rauc/ca_passphrase.txt
CA_PASSPHRASE 		?= your_strong_passphrase # Set in your environment or Makefile
# chmod 600 $(CERTS_DIR)/rauc/ca_passphrase.txt  # VERY IMPORTANT: Restrict permissions

# Function to check file permissions
check_file_permissions = \
	if [ ! -f "$1" ]; then \
			echo "ERROR: File '$1' does not exist."; \
			exit 1; \
	elif [ "$(stat -c %a "$1")" != "600" ]; then \
			echo "ERROR: File '$1' has incorrect permissions. Must be 600 (currently $(stat -c %a "$1"))."; \
			exit 1; \
	fi

$(BASE)/meta/%.meta:
	$(Q)$(call MESSAGE,"[ Create target specific meta files ]")
	@mkdir -p $(BASE)/meta
	@echo "TARGET_ORG=\"$(ORG)\"" > $@
	@echo "TARGET_CN=\"$*\"" >> $@ # CN is now target-specific
	@echo "TARGET_EXTRA_INFO=\"Target $* specific information\"" >> $@ #Added extra info

$(BASE)/root/ca.cert.pem:
	$(Q)$(call MESSAGE,"[ Build RAUC Root CA ]")
	@mkdir -p $(BASE)/{root,private,certs} $(BASE)/root/private $(BASE)/meta
	@touch $(BASE)/index.txt
	@echo 01 > $(BASE)/serial
	@if [ ! -s "$(CA_PASSPHRASE_FILE)" ]; then \
		echo "ERROR: Passphrase file '$(CA_PASSPHRASE_FILE)' is empty or does not exist."; \
		exit 1; \
	fi
	#@$(call check_file_permissions,$(CA_PASSPHRASE_FILE)) # Check permissions
	@openssl genrsa -out $(BASE)/root/private/ca.key.pem -passout file:$(CA_PASSPHRASE_FILE) 4096|| { \
            echo "ERROR: Failed to generate CA private key. Check passphrase or OpenSSL installation."; \
            exit 1; \
        }
	# Absolute path! of OPENSSL.con
	@cd $(RAUC_DIR) && openssl req -new -config $(OPENSSL_CONF) -key $(BASE)/root/private/ca.key.pem -passin file:$(CA_PASSPHRASE_FILE) -out $(BASE)/root/ca.csr.pem \
			-subj "/O=$(ORG)/CN=$(ORG) $(CA) Root" > /dev/null
	@echo "[OK] Root CA private key '$(BASE)/root/private/ca.key.pem' created."
	@cd $(RAUC_DIR) && openssl ca -batch -config $(OPENSSL_CONF) -selfsign -extensions v3_ca \
			-in $(BASE)/root/ca.csr.pem \
			-out $(BASE)/root/ca.cert.pem \
			-keyfile $(BASE)/root/private/ca.key.pem -passin file:$(CA_PASSPHRASE_FILE) > /dev/null
	@echo "[OK] Certificate '$(BASE)/$*.cert.pem' created."

$(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-rauc-certs): %-rauc-certs: $(BASE)/meta/%.meta $(BASE)/root/ca.cert.pem
	$(Q)$(call MESSAGE,"[ Create $*'s RAUC signing key and certificate ]")
	$(Q)eval "$$(cat $(BASE)/meta/$*.meta | awk -F'"' '{print "$$2"}' | paste -sd ' ' -)"
    # $(Q)echo "TARGET_ORG=$$TARGET_ORG"
    # $(Q)echo "TARGET_CN=$$TARGET_CN"
    # $(Q)echo "TARGET_EXTRA_INFO=$$TARGET_EXTRA_INFO"

##	  $(Q)$(shell cat $(BASE)/meta/$*.meta)
##	  @$(foreach kv, $(KEY_VALUES), $(eval $(kv)))
	# $(Q)$(info TARGET_ORG: $(TARGET_ORG))  # Debug line
	# $(Q)$(info TARGET_CN: $(TARGET_CN))    # Debug line
	# $(Q)cd $(RAUC_DIR) && openssl req -newkey rsa:4096 -config $(OPENSSL_CONF) \
	# 		-keyout $(BASE)/private/$*.key.pem \
	# 		-out $(BASE)/$*.csr.pem \
	# 		-subj '$$SUBJECT' > /dev/null
	# $(Q)echo "[OK] Private key '$(BASE)/private/$*.key.pem' created."


$(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-rauc-certs-clean): %-rauc-certs-clean:
	$(Q)$(call MESSAGE,"[ Clean $* 's RAUC certificates ]")
	@rm -rvf $(BASE)/$* $(BASE)/private/$*.key.pem $(BASE)/meta/$*.meta










# 	@$(eval include $(BASE)/meta/$*.meta)
# 	@SUBJECT="/O=$(TARGET_ORG)/CN=$(TARGET_CN)"
# # @echo "DEBUG: TARGET_ORG is: $(TARGET_ORG)"
# # @echo "DEBUG: TARGET_CN is: $(TARGET_CN)"
# # @echo "DEBUG: SUBJECT is: $$SUBJECT"
# 	@cd $(RAUC_DIR) && $(SHELL) -c "openssl req -newkey rsa:4096 -config $(OPENSSL_CONF) \
# 			-keyout $(BASE)/private/$*.key.pem \
# 			-out $(BASE)/$*.csr.pem \
# 			-subj "$$SUBJECT" > /dev/null"
# 	@echo "[OK] Private key '$(BASE)/private/$*.key.pem' created."



