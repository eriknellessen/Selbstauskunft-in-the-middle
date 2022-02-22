SHELL=/bin/bash

PREFIX ?= $(shell pwd)

CONF_FILES = /etc/sysconfig/apache2 /etc/apache2/apache2.conf

.PHONY: apache_module eIDClientCore

all: client server

client: virtualsmartcard

server: virtualsmartcard eIDClientCore apache_module

virtualsmartcard:
	git submodule update --init --recursive
	cd vsmartcard/virtualsmartcard ;\
	autoreconf --verbose --install ;\
	./configure --sysconfdir=/etc ;\
	make ;\
	sudo make install

eIDClientCore:
	git submodule update --init --recursive
	cd eIDClientCore ;\
	make
	
apache_module:
	sed -i '/eIDClientCoreEIDCCBinaryPath \"\"/c\eIDClientCoreEIDCCBinaryPath \"'$(PREFIX)'\/eIDClientCore\/bin\/Test_nPAClientLib_AutentApp\"' apache_module/httpd.conf.eIDClientCore
	sed -i '/eIDClientCoreParserCommand \"\"/c\eIDClientCoreParserCommand \"python '$(PREFIX)'\/apache_module\/parser\/parser.py\"' apache_module/httpd.conf.eIDClientCore
	make -C apache_module
	$(foreach f,$(CONF_FILES),sudo sed -i '/^APACHE_CONF_INCLUDE_FILES=\"\"/c\APACHE_CONF_INCLUDE_FILES=\"'$(PREFIX)'\/apache_module\/httpd.conf.eIDClientCore\"' $(f) || echo Nevermind)
	@echo -e "\nTried to set the correct path in the following configuration files: "$(CONF_FILES)". Please check, if everything is correct and set it manually, if it is not."
