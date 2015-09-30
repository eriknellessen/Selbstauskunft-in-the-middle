SHELL=/bin/bash

PREFIX ?= $(shell pwd)

all: virtualsmartcard eIDClientCore

client: virtualsmartcard

server: virtualsmartcard eIDClientCore

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