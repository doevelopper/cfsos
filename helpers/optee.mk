
CERT_CONFIGS = ca.conf mid.conf my.conf

# Function to generate a certificate based on config
define GENERATE_CERT
$(1)-cert: $(1).csr
    openssl x509 -req -days $(DAYS_VALID) -in $< -CA ca.crt -CAkey ca.key -CAcreateserial -out $@
    @echo "[  Generated $@ ]"
endef

# # Define variables for clarity and reusability (optional)
# PRIVATE_KEY_CA = ca.key
# ROOT_CERT = ca.crt
# MID_CSR = mid.csr
# MID_CERT = mid.crt
# MY_CSR = my.csr
# MY_CERT = my.crt
# DAYS_VALID = 10000


# # ifeq (yes, ${TEST})
# # CXXFLAGS := ${CXXFLAGS} -DDESKTOP_TEST
# # test:
# # $(info ************  TEST VERSION ************)
# # else
# # release:
# # $(info ************ RELEASE VERSIOIN **********)
# # endif

# $(warning "This is a Test Ceritificate Authority, only to be used for testing.")

# # Default goal when running 'make'
# all: ${ROOT_CERT} ${MID_CERT} ${MY_CERT}

# # Generate Root Private Key
# ${PRIVATE_KEY_CA}:
#     openssl genrsa -out ${PRIVATE_KEY_CA} 2048
#     @echo "Generated root private key."

# # Generate Root Certificate
# ${ROOT_CERT}: ${PRIVATE_KEY_CA}
#     openssl req -new -x509 -key ${PRIVATE_KEY_CA} -out ${ROOT_CERT} -days ${DAYS_VALID} -batch
#     @echo "Generated root certificate."

# # Generate Mid CSR and Key (assuming mid.conf exists)
# ${MID_CSR}:
#     openssl req -new -out ${MID_CSR} -config mid.conf
#     @echo "Generated mid CSR."

# # Sign Mid Certificate
# ${MID_CERT}: ${MID_CSR} ${PRIVATE_KEY_CA}
#     openssl x509 -req -in ${MID_CSR} -extfile mid.ext -CA ${ROOT_CERT} -CAkey ${PRIVATE_KEY_CA} -CAcreateserial -out ${MID_CERT} -days ${DAYS_VALID}
#     @echo "Signed mid certificate."

# # Generate My CSR (assuming my.conf exists)
# ${MY_CSR}:
#     openssl req -new -out ${MY_CSR} -config my.conf
#     @echo "Generated my CSR."

# # Sign My Certificate
# ${MY_CERT}: ${MY_CSR} ${MID_CERT}
#     openssl x509 -req -in ${MY_CSR} -CA ${MID_CERT} -CAkey ${MID_CSR} -CAcreateserial -out ${MY_CERT} -days ${DAYS_VALID}
#     @echo "Signed my certificate."

# # Clean up rule (optional)
# clean:
#     rm -f ${PRIVATE_KEY_CA} ${ROOT_CERT} ${MID_CSR} ${MID_CERT} ${MY_CSR} ${MY_CERT} *.srl
#     @echo "Cleaned up certificate files."



# To set up a secure environment for OP-TEE (Open-Source Trusted Execution Environment), TrustZone Firmware (TFA), and an embedded Linux system, you'll need to generate several types of certificates for different purposes. Here's a high-level overview:

# Root CA (Certificate Authority) Certificate: This is the top-level certificate that signs all other certificates in your trust chain. It should be securely stored and not included in your product.
# OP-TEE GlobalPlatform (GP) TA (Trusted Application) Certificates: These certificates are used to sign and authenticate Trusted Applications running within OP-TEE. Each TA should have a unique certificate signed by the Root CA or an intermediate CA specifically designated for TAs.
# Secure Boot Chain Certificates: For the secure boot process in both the normal world (Linux) and secure world (OP-TEE), you'll need a chain of certificates. This includes certificates for the bootloader (U-Boot), kernel, and potentially device-specific secure boot stages. These ensure that each stage of boot verifies the integrity of the next.
# TF-A (Trusted Firmware-A) Certificates: TF-A uses certificates for Secure Boot and Measurement (SBM) to verify the authenticity and integrity of its components. You might need to sign the BL1 (Boot Loader Stage 1), BL2 (Boot Loader Stage 2), EL3 Runtime Software, and potentially other Secure-EL1 payloads with certificates.
# Intermediate CAs: Depending on your security architecture, you may want intermediate CAs for different parts of your system to delegate signing authority while maintaining a clear separation of duties.
# TLS/SSL Certificates: If your embedded Linux system communicates over the network using SSL/TLS (e.g., for HTTPS, MQTT, etc.), you'll need certificates for server authentication and possibly client authentication too.
# Key Management and Storage: Ensure that private keys associated with these certificates are securely stored, often in hardware security modules (HSMs) or Trusted Platform Modules (TPMs), if available on your platform.
# User-Space Application Signing (Optional): If you enforce signature checks for user-space applications, you'll need a certificate to sign those applications.
# Remember, generating and managing these certificates involves careful planning to maintain the security of your system. Each certificate should follow best practices for key length, algorithm choice (e.g., ECC or RSA), and expiration dates. Tools like OpenSSL or mbedtls can be used for certificate generation. Be sure to keep the private keys secure and consider implementing a secure update mechanism for certificates when needed.