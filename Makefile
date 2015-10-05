SHELL=/bin/bash

PREFIX ?= $(shell pwd)

.PHONY: apache_module

all: client server

client: virtualsmartcard

server: virtualsmartcard eIDClientCore apache_module

virtualsmartcard:
	git clone https://github.com/frankmorgner/vsmartcard.git
	cd vsmartcard/virtualsmartcard ;\
	autoreconf --verbose --install ;\
	./configure --sysconfdir=/etc ;\
	make ;\
	sudo make install

eIDClientCore:
	git clone https://github.com/BeID-lab/eIDClientCore.git
	cd eIDClientCore ;\
	make
	
apache_module:
	sed -i '/char eIDCCBinary\[\] = \"\";/c\char eIDCCBinary\[\] = \"'$(PREFIX)'\/bin\/Test_nPAClientLib_AutentApp\";' apache_module/mod_eIDClientCore.c
	make -C apache_module
	sudo sed -i '/APACHE_CONF_INCLUDE_FILES=\"\"/c\APACHE_CONF_INCLUDE_FILES=\"'$(PREFIX)'\/apache_module\/httpd.conf.eIDClientCore\"' /etc/sysconfig/apache2 