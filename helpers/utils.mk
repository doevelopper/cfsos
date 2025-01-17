ifndef UNAME_S
UNAME_S := $(shell uname -s)
endif

ifndef UNAME_P
UNAME_P := $(shell uname -p)
endif

ifndef UNAME_M
UNAME_M := $(shell uname -m)
endif

ifndef NVCC_VERSION
	ifeq ($(call,$(shell which nvcc))$(.SHELLSTATUS),0)
		NVCC_VERSION := $(shell nvcc --version | egrep -o "V[0-9]+.[0-9]+.[0-9]+" | cut -c2-)
	endif
endif


# clock_gettime came in POSIX.1b (1993)
# CLOCK_MONOTONIC came in POSIX.1-2001 / SUSv3 as optional
# posix_memalign came in POSIX.1-2001 / SUSv3
# M_PI is an XSI extension since POSIX.1-2001 / SUSv3, came in XPG1 (1985)
CFLAGS   += -D_XOPEN_SOURCE=600
CXXFLAGS += -D_XOPEN_SOURCE=600

# Somehow in OpenBSD whenever POSIX conformance is specified
# some string functions rely on locale_t availability,
# which was introduced in POSIX.1-2008, forcing us to go higher
ifeq ($(UNAME_S),OpenBSD)
	CFLAGS   += -U_XOPEN_SOURCE -D_XOPEN_SOURCE=700
	CXXFLAGS += -U_XOPEN_SOURCE -D_XOPEN_SOURCE=700
endif

# Data types, macros and functions related to controlling CPU affinity
# are available on Linux through GNU extensions in libc
ifeq ($(UNAME_S),Linux)
	CFLAGS   += -D_GNU_SOURCE
	CXXFLAGS += -D_GNU_SOURCE
endif

# TODO: support Windows
ifeq ($(filter $(UNAME_S),Linux Darwin DragonFly FreeBSD NetBSD OpenBSD Haiku),$(UNAME_S))
	CFLAGS   += -pthread
	CXXFLAGS += -pthread
endif


#
# Print build information
#

$(info I whisper.cpp build info: )
$(info I UNAME_S:  $(UNAME_S))
$(info I UNAME_P:  $(UNAME_P))
$(info I UNAME_M:  $(UNAME_M))
$(info I CFLAGS:   $(CFLAGS))
$(info I CXXFLAGS: $(CXXFLAGS))
$(info I LDFLAGS:  $(LDFLAGS))
$(info I CC:       $(CCV))
$(info I CXX:      $(CXXV))
$(info )


ifdef WHISPER_CUBLAS
$(info !!!!)
$(info WHISPER_CUBLAS is deprecated and will be removed in the future. Use WHISPER_CUDA instead.)
$(info !!!!)
$(info )
endif



.PHONY: samples
samples:
	@echo "Downloading samples..."
	@mkdir -p samples
	@wget --quiet --show-progress -O samples/gb0.ogg https://upload.wikimedia.org/wikipedia/commons/2/22/George_W._Bush%27s_weekly_radio_address_%28November_1%2C_2008%29.oga
	@wget --quiet --show-progress -O samples/gb1.ogg https://upload.wikimedia.org/wikipedia/commons/1/1f/George_W_Bush_Columbia_FINAL.ogg