SHELL := /bin/bash
KVER  ?= $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
FIRMWAREDIR := /lib/firmware/
PWD := $(shell pwd)
CLR_MODULE_FILES := *.mod.c *.mod *.o .*.cmd *.ko *~ .tmp_versions* modules.order Module.symvers
SYMBOL_FILE := Module.symvers
MODDESTDIR := /lib/modules/$(KVER)/kernel/drivers/bluetooth

ifeq ("","$(wildcard MOK.der)")
NO_SKIP_SIGN := y
endif

#Handle the compression option for modules in 3.18+
ifneq ("","$(wildcard $(MODDESTDIR)/*.ko.gz)")
COMPRESS_GZIP := y
endif
ifneq ("","$(wildcard $(MODDESTDIR)/*.ko.xz)")
COMPRESS_XZ := y
endif

EXTRA_CFLAGS += -O2
KEY_FILE ?= MOK.der

obj-m	+= btusb.o
obj-m		+= btrtl.o

ccflags-y += -D__CHECK_ENDIAN__

.PHONY: all install clean sign sign-install

all:
	$(MAKE) -C $(KSRC) M=$(PWD) modules
install: all

	@mkdir -p $(MODDESTDIR)
	@install -p -D -m 644 *.ko $(MODDESTDIR)
ifeq ($(COMPRESS_GZIP), y)
	@gzip -f $(MODDESTDIR)/btusb.ko
	@gzip -f $(MODDESTDIR)/btrtl.ko
endif
ifeq ($(COMPRESS_XZ), y)
	@xz -f $(MODDESTDIR)/btusb.ko
	@xz -f $(MODDESTDIR)/btrtl.ko
endif
	@depmod -a $(KVER)

	@mkdir -p /lib/firmware/rtl_bt/
	@cp *.bin /lib/firmware/rtl_bt/.

	@echo "Install btusb/btrtl SUCCESS"

clean:
	@rm -fr *.mod.c *.mod *.o .*.cmd .*.o.cmd *.ko *~ .*.o.d .cache.mk
	@rm -fr .tmp_versions
	@rm -fr Modules.symvers
	@rm -fr Module.symvers
	@rm -fr Module.markers
	@rm -fr modules.order

sign:
ifeq ($(NO_SKIP_SIGN), y)
	@openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=Custom MOK/"
	@mokutil --import MOK.der
else
	echo "Skipping key creation"
endif
	@$(KSRC)/scripts/sign-file sha256 MOK.priv MOK.der btusb.ko
	@$(KSRC)/scripts/sign-file sha256 MOK.priv MOK.der btrtl.ko

sign-install: all sign install

