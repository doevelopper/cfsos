# #
# ##################################################################################################################################
# ##################################################################################################################################

SUBJECT_CA = /C=MU/ST=Province of Munin/L=Munin Town/O=Munin Inc./OU=CA/CN=127.0.0.1/emailAddress=munin@example.org/
SUBJECT_MASTER = /C=MU/ST=Province of Munin/L=Munin Town/O=Munin Inc./OU=Master/CN=127.0.0.1/emailAddress=munin@example.org/
SUBJECT_NODE = /C=MU/ST=Province of Munin/L=Munin Town/O=Munin Inc./OU=Node/CN=127.0.0.1/emailAddress=munin@example.org/

OPENSSL_CMD=workspace/raspberrypi3_64-build-artifacts/host/bin/openssl
OPENSSL_CONF=../../apps/openssl.cnf
export OPENSSL_CONF

OUTPUT_DIR=certs
OPENSSL_CNF=openssl.cnf
DIR=./$(CERTS_DIR)/demoCA

RAUC_ORG 	:= $(if $(RAUC_ORG),$(RAUC_ORG),$("ACME Systems Inc."))
RAUC_CA 	:= $(or $(RAUC_CA),"RAUC CA")
RAUC_CN 	:= $(or $(RAUC_CN),"Taz")

$(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-web-self-signed): %-web-self-signed: ##.root-ssl .server-ssl .client-ssl
	$(Q)$(call MESSAGE,"    [Rebuild $* self-signed root/server/client certs/keys in a consistent way.]")

	$(Q)rm -vf $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/{*.crt,*.key,*.srl}

# 	$(Q)$(call MESSAGE,"    [Regenerating $* Root CA.]")
# 	$(Q)$(BLRT_OOSB)/$*-build-artifacts/host/bin/openssl req -new -sha256 -nodes -newkey rsa:2048 -config  $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/root.cnf -keyout /tmp/root.key -out /tmp/root.csr
# 	$(Q)$(BLRT_OOSB)/$*-build-artifacts/host/bin/openssl x509 -req -days 3653 -sha256 -in /tmp/root.csr -extfile $(BLRT_OOSB)/$*-build-artifacts/target/etc/ssl/openssl.cnf -extensions v3_ca -signkey /tmp/root.key -out $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/root.crt
# # #/etc/ssl/openssl.cnf# host/etc/ssl/openssl.cnf

# 	$(Q)$(call MESSAGE,"    [Regenerating $* Server Certs.]")
# 	$(Q)$(BLRT_OOSB)/$*-build-artifacts/host/bin/openssl req -new -sha256 -nodes -newkey rsa:2048 -config $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/server.cnf -keyout $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/server.key -out /tmp/server.csr
# 	$(Q)$(BLRT_OOSB)/$*-build-artifacts/host/bin/openssl x509 -req -days 3653 -sha256 -extfile $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/server.cnf -extensions req_ext -CA $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/root.crt -CAkey /tmp/root.key -CAcreateserial -in /tmp/server.csr -out $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/server.crt

# 	$(Q)$(call MESSAGE,"    [Regenerating $* Client Certs.]")
# 	$(Q)$(BLRT_OOSB)/$*-build-artifacts/host/bin/openssl req -new -sha256 -nodes -newkey rsa:2048 -config $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/clients.cnf  -keyout $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/clients.key -out /tmp/clients.csr
# 	$(Q)$(BLRT_OOSB)/$*-build-artifacts/host/bin/openssl x509 -req -days 3653 -sha256 -CA $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/root.crt -CAkey /tmp/root.key -CAcreateserial -in /tmp/clients.csr -out $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/clients.crt


$(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-certificate-expiry): %-certificate-expiry:  # Generate various certificates
	$(Q)$(call MESSAGE,"    [Check $* certificates expiry dates.]")
	$(Q)$(foreach h,$(wildcard $(BLRT_EXT)/board/$(subst $(UNDERS),$(DASH),$*)/certs/*.crt), echo -e "\n\n$(h)\n"; $(BLRT_OOSB)/$*-build-artifacts/host/bin/openssl x509 -noout -in $(h) -dates;)


$(foreach defconfig,$(SUPPORTED_TARGETS),$(defconfig)-certificate): %-certificate:  # Generate various certificates
	$(Q)$(call MESSAGE,"[ $*'s certificates generation a new]")

# @if grep -q 'BR2_PACKAGE_LIBOPENSSL_BIN=y' $(BLRT_OOSB)/$*-build-artifacts/.config; 	\
# then 																					\
# 	echo "--- Certificates $* generation---" ;  										\
# 	mkdir -pv $(CERTS_DIR)/openssl-ca/{root,private,certs}           					\
# 	touch "$(CERTS_DIR)/openssl-ca/index.txt" 											\
# 	test -f $(CERTS_DIR)/openssl-ca/serial || echo 00 > $(CERTS_DIR)/openssl-ca/serial 	\
# else 																					\
# 	echo "--- (SKIP cert generatrion) $* ---" ; 										\
# fi \


# /home/hroland/developpements/cfsos/workspace/raspberrypi3_64build-artifacts/host/bin/openssl 

# .e2e:
# 	mkdir CA
# 	mkdir CA/newcerts CA/private
# 	touch CA/index.txt
# 	echo '01' > CA/serial
# 	openssl req -new -nodes -x509 -extensions v3_ca -subj "$(SUBJECT_CA)" -keyout CA/private/ca_key.pem -out CA/ca_cert.pem -days 3650 -config ./openssl.cnf
# 	openssl req -new -nodes -subj "$(SUBJECT_NODE)" -keyout node_key.pem -out node_req.pem -config ./openssl.cnf
# 	openssl req -new -nodes -subj "$(SUBJECT_MASTER)" -keyout master_key.pem -out master_req.pem -config ./openssl.cnf
# 	yes | openssl ca -out node_cert.pem -in node_req.pem -config ./openssl.cnf -days 3650
# 	yes | openssl ca -out master_cert.pem -in master_req.pem -config ./openssl.cnf -days 3650



# CERTS_DIR := certs
# SHELL     := bash

# $(CERTS_DIR):
# 	@mkdir -p $(CERTS_DIR)

# .PHONY: clean-certs
# clean-certs:  ## Cleans the certificates
# 	@rm -rf $(CERTS_DIR)

# ca/%: $(CERTS_DIR)  ## Generates the CA
# 	@echo "Generating $(*) CA"
# 	@openssl genrsa -out "$(CERTS_DIR)/ca.key" 4096
# 	@openssl req -x509 -new -sha256 -nodes -days 365 -key "$(CERTS_DIR)/ca.key" -out "$(CERTS_DIR)/ca.crt" \
# 		-subj "/C=US/ST=California/O=Tetrate/OU=Engineering/CN=$(*)" \
# 		-addext "basicConstraints=critical,CA:true,pathlen:1" \
# 		-addext "keyUsage=critical,digitalSignature,nonRepudiation,keyEncipherment,keyCertSign" \
# 		-addext "subjectAltName=DNS:$(*)"

# certificate/%: $(CERTS_DIR)  ## Generates the certificates
# 	@echo "Generating $(*) cert"
# 	@openssl genrsa -out "$(CERTS_DIR)/$(*).key" 2048
# 	@openssl req -new -sha256 -key "$(CERTS_DIR)/$(*).key" -out "$(CERTS_DIR)/$(*).csr" \
# 		-subj "/C=US/ST=California/O=Tetrate/OU=Engineering/CN=$(*)" \
# 		-addext "subjectAltName=DNS:$(*)"
# 	@openssl x509 -req -sha256 -days 120 -in "$(CERTS_DIR)/$(*).csr" -out "$(CERTS_DIR)/$(*).crt" \
# 		-CA "$(CERTS_DIR)/ca.crt" -CAkey "$(CERTS_DIR)/ca.key" -CAcreateserial -CAserial $(CERTS_DIR)/ca.srl \
# 		-extfile <(printf "subjectAltName=DNS:$(*)")


# echo "--- Generation $* ca.key---" ;  \
# openssl genrsa -out $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-ca.key 4096 \
# echo "--- Generation $* ca.csr---" ;  \
# openssl req -sha256 -key $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-ca.key -days 365 -new -out $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-ca.csr -config $(CERTS_DIR)/openssl-ca/demo-openssl.cnf -extensions v3_ca -subj "/C=US/ST=Maryland/O=ACME Systems Technologies/CN=Sample CA" \
# echo "--- Generation $* ca.crt---" ;  \
# openssl x509 -sha256 -req -in $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-ca.csr -signkey $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-ca.key -out $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-ca.crt -extfile $(CERTS_DIR)/openssl-ca/demo-openssl.cnf -extensions v3_ca -days 365 \
# echo "--- Generation $* server.key---" ;  \
# openssl genrsa -out $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-server.key 2048 \
# echo "--- Generation $* server.csr---" ;  \
# openssl req -sha256 -key $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-server.key -days 365 -new -out $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-server.csr -config $(CERTS_DIR)/openssl-ca/demo-openssl.cnf -subj "/C=US/ST=Maryland/O=ACME Systems Technologies/CN=test-server" \
# echo "--- Generation $* server.crt---" ;  \
# openssl ca -batch -config $(CERTS_DIR)/openssl-ca/demo-openssl.cnf -in $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-server.csr -out $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-server.crt -outdir . -keyfile $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-ca.key -cert $(CERTS_DIR)/openssl-ca/$(subst $*-,,$@)-ca.crt -days 120 \

# 	@if grep -q 'BR2_TARGET_UBOOT=y' $(BLRT_OOSB)/$*-build-artifacts/.config; then
# 		$(Q)$(call MESSAGE,"[ Generating $* Rauc  certificate]")
# # This is a Test Ceritificate Authority, only to be used for testing.
# # $(Q)$(call MESSAGE,"[ Generating $* Swupdate certificate]")
# # $(Q)$(call MESSAGE,"[ Generating $* Webs certificate]")
# # $(Q)$(call MESSAGE,"[ Generating $* Tee certificate]")
# 	else 
# 		$(Q)$(call MESSAGE,"[ --- (UBOOT not activated SKIPPING $@ ---]")
# 	fi


# create_dirs:
#  	mkdir -p $(CERTS_DIR)/rauc/{root,private,certs}
#  	mkdir -p $(CERTS_DIR)/rauc/root/private

# 	$(Q)$(call MESSAGE,"BLRT [Create a certificate authority $@ ]")
# 	$(Q)$(OPENSSL_CMD) genrsa -out caKey.pem 2048
# 	$(Q)$(OPENSSL_CMD) req -x509 -new -nodes -key caKey.pem -days 100000 -out caCert.pem -subj "/CN=webhook_imagepolicy_ca"

# 	$(Q)$(call MESSAGE,"BLRT [Create a second certificate authority $@ ]")
# 	$(Q)$(OPENSSL_CMD) genrsa -out badCAKey.pem 2048
# 	$(Q)$(OPENSSL_CMD) req -x509 -new -nodes -key badCAKey.pem -days 100000 -out badCACert.pem -subj "/CN=webhook_imagepolicy_ca"

# 	$(Q)$(call MESSAGE,"BLRT [Create a server certiticate $@ ]")
# 	$(Q)$(OPENSSL_CMD) genrsa -out serverKey.pem 2048
# 	$(Q)$(OPENSSL_CMD) req -new -key serverKey.pem -out server.csr -subj "/CN=webhook_imagepolicy_server" -config server.conf
# 	$(Q)$(OPENSSL_CMD) x509 -req -in server.csr -CA caCert.pem -CAkey caKey.pem -CAcreateserial -out serverCert.pem -days 100000 -extensions v3_req -extfile server.conf

# 	$(Q)$(call MESSAGE,"BLRT [Create a client certiticate $@ ]")
# 	$(Q)$(OPENSSL_CMD) genrsa -out clientKey.pem 2048
# 	$(Q)$(OPENSSL_CMD) req -new -key clientKey.pem -out client.csr -subj "/CN=webhook_imagepolicy_client" -config client.conf
# 	$(Q)$(OPENSSL_CMD) x509 -req -in client.csr -CA caCert.pem -CAkey caKey.pem -CAcreateserial -out clientCert.pem -days 100000 -extensions v3_req -extfile client.conf


# .PHONY: all root-ssl server-ssl client-ssl

# # Rebuilds self-signed root/server/client certs/keys in a consistent way
# all: root-ssl server-ssl client-ssl
# 	rm -f .srl


# true && openssl req -newkey rsa:2048 -nodes -keyout root_key.pem -x509 -days 3650 -out root_certificate.pem \
# 	-subj "/C=CA/O=TrollStore/OU=$1/CN=TrollStore iPhone Root CA" \
# 	-addext "1.2.840.113635.100.6.2.18=DER:0500" \
# 	-addext "basicConstraints=critical, CA:true" -addext "keyUsage=critical, digitalSignature, keyCertSign, cRLSign"
# true && openssl req -newkey rsa:2048 -nodes -keyout codeca_key.pem -out codeca_certificate.csr \
# 	-subj "/C=CA/O=TrollStore/OU=$1/CN=TrollStore iPhone Certification Authority" \
# 	-addext "1.2.840.113635.100.6.2.18=DER:0500" \
# 	-addext "basicConstraints=critical, CA:true" -addext "keyUsage=critical, keyCertSign, cRLSign"
# true && openssl x509 -req -CAkey root_key.pem -CA root_certificate.pem -days 3650 \
# 	-in codeca_certificate.csr -out codeca_certificate.pem -CAcreateserial -copy_extensions copyall
# true && openssl req -newkey rsa:2048 -nodes -keyout dev_key.pem -out dev_certificate.csr \
# 	-subj "/C=CA/O=TrollStore/OU=$1/CN=TrollStore iPhone OS Application Signing" \
# 	-addext "basicConstraints=critical, CA:false" \
# 	-addext "keyUsage = critical, digitalSignature" -addext "extendedKeyUsage = codeSigning" \
# 	-addext "1.2.840.113635.100.6.1.3=DER:0500"
# true && openssl x509 -req -CAkey codeca_key.pem -CA codeca_certificate.pem -days 3650 \
# 	-in dev_certificate.csr -out dev_certificate.pem -CAcreateserial -copy_extensions copyall
# true && cat codeca_certificate.pem root_certificate.pem >certificate_chain.pem
# true && /usr/bin/openssl pkcs12 -export -in dev_certificate.pem -inkey dev_key.pem -certfile certificate_chain.pem \
# 	-keypbe NONE -certpbe NONE -passout pass: \
# 	-out victim.p12 -name "TrollStore iPhone OS Application Signing"

	
# build-rauc-root-ca : create_dirs
# 	$(Q)touch "$(CERTS_DIR)/rauc/index.txt"
# 	$(Q)echo 01 > $(CERTS_DIR)/rauc/serial
# 	# $(Q)openssl req -newkey rsa -keyout "$(CERTS_DIR)/rauc/root/private/ca.key.pem" -out "$(CERTS_DIR)/rauc/root/ca.csr.pem" -subj "/O=$(RAUC_CA)/CN=$(RAUC_CA) ${RAUC_CA} Root" > /dev/null 2>&1
# #	$(Q)openssl ca -batch -selfsign -extensions v3_ca -in "$(CERTS_DIR)/rauc/root/ca.csr.pem" -out "$(CERTS_DIR)/rauc/root/ca.cert.pem" -keyfile "$(CERTS_DIR)/rauc/root/private/ca.key.pem" > /dev/null 2>&1

# create-rauc-signing-key : build-rauc-root-ca
# 	$(Q)openssl req -newkey rsa:4096  -keyout "$(CERTS_DIR)/rauc/private/$(RAUC_CN).key.pem" -out "$(CERTS_DIR)/rauc/$(RAUC_CN).csr.pem" -subj "/O=${ORG}/CN=$(RAUC_CN)" > /dev/null 2>&1
# 	$(Q)openssl ca -batch -extensions v3_leaf -in "$(CERTS_DIR)/rauc/$(RAUC_CN).csr.pem" -out "$(CERTS_DIR)/rauc/$(RAUC_CN).cert.pem" > /dev/null 2>&1


# # all: create_https_certificate create_rauc_ca create_rauc_bundle_keys create_https_certificate_file create_rauc_ca_file create_rauc_bundle_keys_file

# create_https_certificate:
# 	mkdir -p $(CERTS_DIR)/https
# 	openssl req -x509 -newkey rsa:4096 -keyout $(CERTS_DIR)/https/https_key.pem -out $(CERTS_DIR)/https/https_cert.pem -days 365 -nodes -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=www.example.com"

# # create_rauc_ca:
# # 	mkdir -p $(OUTPUT_DIR)
# # 	openssl genpkey -algorithm RSA -out $(OUTPUT_DIR)/ca.key.pem
# # 	openssl req -key $(OUTPUT_DIR)/ca.key.pem -new -x509 -days 3650 -out $(OUTPUT_DIR)/ca.cert.pem -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=www.example.com"

# # create_rauc_bundle_keys:
# # 	mkdir -p $(OUTPUT_DIR)
# # 	openssl genpkey -algorithm RSA -out $(OUTPUT_DIR)/bundle.key.pem
# # 	openssl req -key $(OUTPUT_DIR)/bundle.key.pem -new -out $(OUTPUT_DIR)/bundle.csr.pem -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=www.example.com"
# # 	openssl x509 -req -in $(OUTPUT_DIR)/bundle.csr.pem -CA $(OUTPUT_DIR)/ca.cert.pem -CAkey $(OUTPUT_DIR)/ca.key.pem -CAcreateserial -out $(OUTPUT_DIR)/bundle.cert.pem -days 3650

# # create_https_certificate_file:
# # 	mkdir -p $(OUTPUT_DIR)
# # 	openssl req -x509 -newkey rsa:4096 -keyout $(OUTPUT_DIR)/https_key.pem -out $(OUTPUT_DIR)/https_cert.pem -days 365 -nodes -config $(OPENSSL_CNF)

# # create_rauc_ca_file:
# # 	mkdir -p $(OUTPUT_DIR)
# # 	openssl genpkey -algorithm RSA -out $(OUTPUT_DIR)/ca.key.pem
# # 	openssl req -key $(OUTPUT_DIR)/ca.key.pem -new -x509 -days 3650 -out $(OUTPUT_DIR)/ca.cert.pem -config $(OPENSSL_CNF)

# # create_rauc_bundle_keys_file:
# # 	mkdir -p $(OUTPUT_DIR)
# # 	openssl genpkey -algorithm RSA -out $(OUTPUT_DIR)/bundle.key.pem
# # 	openssl req -key $(OUTPUT_DIR)/bundle.key.pem -new -out $(OUTPUT_DIR)/bundle.csr.pem -config $(OPENSSL_CNF)
# # 	openssl x509 -req -in $(OUTPUT_DIR)/bundle.csr.pem -CA $(OUTPUT_DIR)/ca.cert.pem -CAkey $(OUTPUT_DIR)/ca.key.pem -CAcreateserial -out $(OUTPUT_DIR)/bundle.cert.pem -days 3650 -config $(OPENSSL_CNF)



# https_certificate:
# 	mkdir -p $(OUTPUT_DIR)
# 	env DIR=$(DIR) openssl req -x509 -newkey rsa:4096 -keyout $(OUTPUT_DIR)/https_key.pem -out $(OUTPUT_DIR)/https_cert.pem -days 365 -nodes -config $(OPENSSL_CNF)

# rauc_ca:
# 	mkdir -p $(OUTPUT_DIR)
# 	env DIR=$(DIR) openssl genpkey -algorithm RSA -out $(OUTPUT_DIR)/ca.key.pem
# 	env DIR=$(DIR) openssl req -key $(OUTPUT_DIR)/ca.key.pem -new -x509 -days 3650 -out $(OUTPUT_DIR)/ca.cert.pem -config $(OPENSSL_CNF)

# rauc_bundle_keys:
# 	mkdir -p $(OUTPUT_DIR)
# 	env DIR=$(DIR) openssl genpkey -algorithm RSA -out $(OUTPUT_DIR)/bundle.key.pem
# 	env DIR=$(DIR) openssl req -key $(OUTPUT_DIR)/bundle.key.pem -new -out $(OUTPUT_DIR)/bundle.csr.pem -config $(OPENSSL_CNF)
# 	env DIR=$(DIR) openssl x509 -req -in $(OUTPUT_DIR)/bundle.csr.pem -CA $(OUTPUT_DIR)/ca.cert.pem -CAkey $(OUTPUT_DIR)/ca.key.pem -CAcreateserial -out $(OUTPUT_DIR)/bundle.cert.pem -days 3650 -config $(OPENSSL_CNF)


