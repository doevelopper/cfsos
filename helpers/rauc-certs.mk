# Makefile for generating RAUC certificates

# --- Configuration ---
# These variables should be customized to your needs.

# Common Name for the Certificate Authority (CA)
CA_CN ?= My RAUC CA

# Common Name for the device certificate
DEVICE_CN ?= my-device

# Validity period for certificates (in days)
VALIDITY ?= 3650

# Output directory for certificates
OUTPUT_DIR ?= certs

# OpenSSL configuration file (optional)
OPENSSL_CONF ?= openssl.cnf

# --- Targets ---

all: ca-key ca-cert device-key device-cert

ca-key: $(OUTPUT_DIR)/ca.key
$(OUTPUT_DIR)/ca.key:
        @mkdir -p $(OUTPUT_DIR)
        openssl genrsa -out $@ 4096

ca-cert: $(OUTPUT_DIR)/ca.crt
$(OUTPUT_DIR)/ca.crt: $(OUTPUT_DIR)/ca.key
        openssl req -x509 -new -nodes -key $< -sha256 \
                -days $(VALIDITY) \
                -out $@ \
                -subj "/CN=$(CA_CN)" \
                $(if $(OPENSSL_CONF),-config $(OPENSSL_CONF))

device-key: $(OUTPUT_DIR)/device.key
$(OUTPUT_DIR)/device.key:
        openssl genrsa -out $@ 4096

device-cert: $(OUTPUT_DIR)/device.crt
$(OUTPUT_DIR)/device.crt: $(OUTPUT_DIR)/device.key $(OUTPUT_DIR)/ca.crt $(OUTPUT_DIR)/ca.key
        openssl req -new -key $< -sha256 \
                -out $(OUTPUT_DIR)/device.csr \
                -subj "/CN=$(DEVICE_CN)" \
                $(if $(OPENSSL_CONF),-config $(OPENSSL_CONF))
        openssl x509 -req -in $(OUTPUT_DIR)/device.csr -CA $(OUTPUT_DIR)/ca.crt \
                -CAkey $(OUTPUT_DIR)/ca.key -CAcreateserial \
                -out $@ -days $(VALIDITY) -sha256 \
                $(if $(OPENSSL_CONF),-extfile $(OPENSSL_CONF) -extensions v3_req)

# Create a combined certificate and key file for RAUC (PKCS#12)
device-pkcs12: $(OUTPUT_DIR)/device.p12
$(OUTPUT_DIR)/device.p12: $(OUTPUT_DIR)/device.crt $(OUTPUT_DIR)/device.key $(OUTPUT_DIR)/ca.crt
        openssl pkcs12 -export -out $@ -inkey $(OUTPUT_DIR)/device.key \
                -in $(OUTPUT_DIR)/device.crt -certfile $(OUTPUT_DIR)/ca.crt

clean:
        rm -rf $(OUTPUT_DIR)

.PHONY: all clean ca-key ca-cert device-key device-cert device-pkcs12



# [req]
# distinguished_name = req_distinguished_name
# prompt = no
# x509_extensions = v3_ca # For CA certificate
# [req_distinguished_name]
# C = US
# ST = CA
# L = MyCity
# O = MyOrganization
# OU = MyUnit
# [v3_ca]
# basicConstraints = CA:TRUE
# subjectKeyIdentifier = hash
# authorityKeyIdentifier = keyid:always,issuer
# [v3_req]
# basicConstraints = CA:FALSE
# subjectKeyIdentifier = hash
# authorityKeyIdentifier = keyid:always,issuer
# keyUsage = digitalSignature, keyEncipherment
# extendedKeyUsage = clientAuth