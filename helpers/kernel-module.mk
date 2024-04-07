##  enable building KO out of br2 by leveraging infra already pipulated by BR2


BLRT_STAGING    ?=      <~/buildroot/output>
ARCH            :=      arm
COMPILER        :=      $(BLRT_STAGING)/host/bin/arm-buildroot-linux-gnueabihf-
KERNELDIR       :=      $(BLRT_STAGING)/build/linux-custom
obj-m           :=      call_dev.o response.o pdd.o platform_driver.o
PWD             :=      $(shell pwd)

INCLUDES        :=      -I. -I$(BLRT_STAGING)/target/includes
LIBS            :=      -L$(BLRT_STAGING)/target/lib
LDFLAGS         +=      -L$(SRC_DIR) -Wl,-R$(SRC_DIR) '-Wl,-R$$ORIGIN'

drivers:
    $(MAKE) -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(COMPILER) modules

userapp: call_app.c
    $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(COMPILER) -o $@ $< $(CFLAGS) $(LDFLAGS)

#grandprix: gptc.cpp
#   $(MAKE) ARCH=$(ARCH) 


# @see also https://stackoverflow.com/questions/74908314/how-to-customise-buildroot-external-modules

CROSS_COMPILE=$(COMPILER)cc -o $@ $<

clean:
    $(MAKE) -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) clean