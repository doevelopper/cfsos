# Makefile for generating self-signed certificates for web client and web server

WEB_CERTS_DIR 		?= $(CERTS_DIR)/web

# --- Configuration ---
export OPENSSL 			:= openssl
export KEY_SIZE 		:= 2048
export DAYS 			:= 3650 # Root CA valid for 10 years
export SERVER_DAYS 		:= 365
export CLIENT_DAYS 		:= 365
export COMMON_NAME_ROOT := myrootca.com


define generate_root_ca
$(1)/rootCA.key:
        mkdir -p $(1)
        $(OPENSSL) genrsa -out $@ $(KEY_SIZE)

$(1)/rootCA.crt: $(1)/rootCA.key
        $(OPENSSL) req -x509 -new -nodes -key $< -days $(DAYS) -out $@ \
                -subj "/C=US/ST=CA/L=Springfield/O=My Root CA Organization/CN=$(COMMON_NAME_ROOT)"
endef

define server_targets
$1: $1-client $1-generate-server-certificate

$1-generate-server-certificate: $(3)/$1-server.crt $(3)/$1-server.pfx

$1-client: $(3)/$1-client.crt $(3)/$1-client.pfx

$(3)/$1-server.key:
        $(OPENSSL) genrsa -out $@ $(KEY_SIZE)

$(3)/$1-server.csr: $(3)/$1-server.key
        $(OPENSSL) req -new -key $< -out $@ -subj "/C=US/ST=CA/L=Springfield/O=My Server Organization/CN=$1.example.com"

$(3)/$1-server.crt: $(3)/$1-server.csr $(call generate_root_ca,$(3))
        $(OPENSSL) x509 -req -in $< -CA $(3)/rootCA.crt -CAkey $(3)/rootCA.key -CAcreateserial -out $@ -days $(SERVER_DAYS)

$(3)/$1-server.pfx: $(3)/$1-server.key $(3)/$1-server.crt
        $(OPENSSL) pkcs12 -export -out $@ -inkey $< -in $1-server.crt -certfile $(3)/rootCA.crt -password pass:password

$(3)/$1-client.key:
        $(OPENSSL) genrsa -out $@ $(KEY_SIZE)

$(3)/$1-client.csr: $(3)/$1-client.key
        $(OPENSSL) req -new -key $< -out $@ -subj "/C=US/ST=CA/L=Springfield/O=My Client Organization/CN=client.$1.example.com"

$(3)/$1-client.crt: $(3)/$1-client.csr $(call generate_root_ca,$(3))
        $(OPENSSL) x509 -req -in $< -CA $(3)/rootCA.crt -CAkey $(3)/rootCA.key -CAcreateserial -out $@ -days $(CLIENT_DAYS)

$(3)/$1-client.pfx: $(3)/$1-client.key $(3)/$1-client.crt
        $(OPENSSL) pkcs12 -export -out $@ -inkey $< -in $1-client.crt -certfile $(3)/rootCA.crt -password pass:password
endef

define generate_certs
	$(call server_targets,$1,$1,$2)
endef

# $(foreach server,$(SUPPORTED_TARGETS),$(eval $(call generate_certs,$(server),certs)))


# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-server-key): %-server-key:
# 	$(Q)$(call MESSAGE,"[ Generate $*'s server certificates]")
# 	$(Q)$(MAKE) $(BLRT_MAKEARGS) BR2_CCACHE_DIR=$(BLRT_PACKAGE_DIR)/cache/cc/$* O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)
# 	@$(OPENSSL) genrsa -out $@ $(KEY_SIZE)
# 	@rm -rvf $(BASE)/$* $(BASE)/private/$*.key.pem $(BASE)/meta/$*.meta

# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-server.csr): %-server.csr:
# 	$(Q)$(call MESSAGE,"[ Generate $*'s server certificates]")

# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-server.crt): %-server.crt:
# 	$(Q)$(call MESSAGE,"[ Generate $*'s server certificates]")

# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-server.pfx): %-server.pfx:
# 	$(Q)$(call MESSAGE,"[ Generate $*'s server certificates]")


# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-generate-server-certificate): %-generate-server-certificate: %-server-key
# 	$(Q)$(call MESSAGE,"[ Generate $*'s server certificates]")


# $(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-generate-server-key): %-generate-server-key:
# 	$(Q)$(call MESSAGE,"[ Generate $*'s cliebt certificates]")



# # Default goal
# .PHONY: all
# all: server-cert client-cert

# # Create certificates directory
# $(CERT_DIR):
# 	mkdir -p $(CERT_DIR)

# # Generate server key
# $(SERVER_KEY): | $(CERT_DIR)
# 	openssl genpkey -algorithm RSA -out $(SERVER_KEY) -pkeyopt rsa_keygen_bits:2048

# # Generate server CSR
# $(SERVER_CSR): $(SERVER_KEY)
# 	openssl req -new -key $(SERVER_KEY) -out $(SERVER_CSR) -subj "/CN=server"

# # Generate server certificate
# $(SERVER_CERT): $(SERVER_CSR)
# 	openssl x509 -req -days $(DAYS) -in $(SERVER_CSR) -signkey $(SERVER_KEY) -out $(SERVER_CERT)

# # Generate client key
# $(CLIENT_KEY): | $(CERT_DIR)
# 	openssl genpkey -algorithm RSA -out $(CLIENT_KEY) -pkeyopt rsa_keygen_bits:2048

# # Generate client CSR
# $(CLIENT_CSR): $(CLIENT_KEY)
# 	openssl req -new -key $(CLIENT_KEY) -out $(CLIENT_CSR) -subj "/CN=client"

# # Generate client certificate
# $(CLIENT_CERT): $(CLIENT_CSR)
# 	openssl x509 -req -days $(DAYS) -in $(CLIENT_CSR) -signkey $(CLIENT_KEY) -out $(CLIENT_CERT)

# # Phony targets
# .PHONY: server-cert client-cert clean

# # Generate server certificate
# server-cert: $(SERVER_CERT)

# # Generate client certificate
# client-cert: $(CLIENT_CERT)

# # Clean generated files
# clean:
# 	rm -rf $(CERT_DIR)