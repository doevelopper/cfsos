# ```makefile
# Makefile for generating RAUC certificates (ported from shell script)

# --- Configuration ---

BASE ?= openssl-ca
ORG ?= Test Org
CA ?= RAUC CA
OPENSSL_CONF ?= openssl.cnf

# --- Targets ---

all: help

help:
        @echo "OpenSSL CA for RAUC certificates"
        @echo "Usage: make <target>"
        @echo ""
        @echo "Targets:"
        @echo "  build-root-ca     Build root CA and directory structure"
        @echo "  create-signing-key CN=<common_name> Create code signing key"
        @echo "  clean             Remove generated files"

build-root-ca: $(BASE)/root/ca.cert.pem

$(BASE)/root/ca.cert.pem:
        @if [ -d "$(BASE)" ]; then \
                echo "[ERROR] Directory '$(BASE)' already exists!"; \
                exit 1; \
        fi
        @mkdir -p $(BASE)/{root,private,certs} $(BASE)/root/private
        @touch $(BASE)/index.txt
        @echo 01 > $(BASE)/serial
        @echo "ORG=\"$(ORG)\"" > $(BASE)/meta
        @echo "CA=\"$(CA)\"" >> $(BASE)/meta
        @openssl req -newkey rsa \
                -keyout $(BASE)/root/private/ca.key.pem \
                -out $(BASE)/root/ca.csr.pem \
                -subj "/O=$(ORG)/CN=$(ORG) $(CA) Root" > /dev/null
        @echo "[OK] Root CA private key '$(BASE)/root/private/ca.key.pem' created."
        @openssl ca -batch -selfsign -extensions v3_ca \
                -in $(BASE)/root/ca.csr.pem \
                -out $(BASE)/root/ca.cert.pem \
                -keyfile $(BASE)/root/private/ca.key.pem > /dev/null
        @echo "[OK] Root CA certificate '$(BASE)/root/ca.cert.pem' created."

create-signing-key:
        @if [ ! -d "$(BASE)" ]; then \
                echo "[SKIP] Directory '$(BASE)' does not exist! Run 'make build-root-ca' first."; \
                exit 1; \
        fi
        @if [ -z "$(CN)" ]; then \
                echo "[ERROR] CN variable is missing! Use 'make create-signing-key CN=<common_name>'"; \
                exit 1; \
        fi
        @if [ -f "$(BASE)/private/$(CN).key.pem" ] || [ -f "$(BASE)/$(CN).cert.pem" ]; then \
                echo "[SKIP] Key and certificate for '$(CN)' already exists!"; \
                exit 1; \
        fi
        @. $(BASE)/meta
        @openssl req -newkey rsa:4096 \
                -keyout $(BASE)/private/$(CN).key.pem \
                -out $(BASE)/$(CN).csr.pem \
                -subj "/O=$(ORG)/CN=$(CN)" > /dev/null
        @echo "[OK] Private key '$(BASE)/private/$(CN).key.pem' created."
        @openssl ca -batch -extensions v3_leaf \
                -in $(BASE)/$(CN).csr.pem \
                -out $(BASE)/$(CN).cert.pem > /dev/null
        @echo "[OK] Certificate '$(BASE)/$(CN).cert.pem' created."

clean:
        rm -rf $(BASE)

.PHONY: all help build-root-ca create-signing-key clean
# ```

# **Key Changes and Explanations:**

# *   **Makefile Structure:** The script's functions are now Makefile targets.
# *   **Variable Usage:** Shell variables like `_ME`, `BASE`, `ORG`, `CA` are now Makefile variables. The color variables are removed as Make doesn't directly support ANSI escape codes in the same way. The OK/ERROR/SKIP messages are simplified.
# *   **Conditional Logic:** The `if` statements in the shell script are translated to Makefile conditional execution using `if [ ... ]; then ... ; fi;`. Note the semicolons are crucial for multi-line shell commands within a Makefile recipe.
# *   **Command Execution:** Shell commands are executed using `@` to suppress command printing (unless there's an error).
# *   **Meta File Handling:** The `. $(BASE)/meta` (source command) is kept, which is a convenient way to load the `ORG` and `CA` variables into the shell environment used by the `openssl` command.
# *   **Command-Line Arguments:** The script's command-line arguments are handled through Makefile variables. Especially important is the `CN` variable for `create-signing-key`, which is now set like this: `make create-signing-key CN=my-device`.
# *   **Error Handling:** The error handling is simplified, but still checks for existing directories and files.
# *   **Help Target:** A `help` target is added to provide usage information, similar to the script's `-h` option.
# *   **Target Dependencies:** The `$(BASE)/root/ca.cert.pem` is used as a prerequisite for the `build-root-ca` target. This ensures that the CA is only built if it doesn't exist.
# *   **.PHONY:** All targets are declared as `.PHONY` to prevent issues with files of the same name.

# **How to Use:**

# 1.  **Save:** Save the Makefile as `Makefile` and the `openssl.cnf` (if you are using it) in the same directory.
# 2.  **Build Root CA:** Run `make build-root-ca`.
# 3.  **Create Signing Key:** Run `make create-signing-key CN=<your_common_name>`, replacing `<your_common_name>` with the desired common name (e.g., `make create-signing-key CN=my-device`).
# 4.  **Clean:** Run `make clean` to remove generated files.

# This Makefile provides a functional equivalent of the provided shell script in a more structured and maintainable way. It leverages Make's built-in features for dependency management and command execution.
