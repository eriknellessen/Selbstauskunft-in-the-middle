FROM debian:buster-20220125

#install deb packages
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y build-essential autoconf libtool pkg-config python3 python3-crypto help2man libpcsclite-dev apache2 apache2-dev subversion libwxgtk3.0-gtk3-dev libcrypto++-dev libcurl4-gnutls-dev expat git gengetopt libqrencode-dev wget

RUN git clone https://gitlab.com/eriknellessen/Selbstauskunft-in-the-middle.git
WORKDIR /Selbstauskunft-in-the-middle
RUN git checkout 99067f9acae0d3f11f97e8fa7a712c8a92beded5

ENV PREFIX=/Selbstauskunft-in-the-middle/
ENV CONF_FILES="/etc/sysconfig/apache2 /etc/apache2/apache2.conf"
RUN git submodule update --init --recursive
WORKDIR /Selbstauskunft-in-the-middle/vsmartcard/virtualsmartcard
RUN autoreconf --verbose --install
RUN ./configure --sysconfdir=/etc
RUN make
RUN make install
WORKDIR /Selbstauskunft-in-the-middle/eIDClientCore
ENV PREFIX=/Selbstauskunft-in-the-middle/eIDClientCore
RUN make asn1c
RUN make openssl
RUN make eIDClient
WORKDIR /Selbstauskunft-in-the-middle
ENV PREFIX=/Selbstauskunft-in-the-middle/
RUN sed -i '/eIDClientCoreEIDCCBinaryPath \"\"/c\eIDClientCoreEIDCCBinaryPath \"'$PREFIX'\/eIDClientCore\/bin\/Test_nPAClientLib_AutentApp\"' apache_module/httpd.conf.eIDClientCore
RUN sed -i '/eIDClientCoreParserCommand \"\"/c\eIDClientCoreParserCommand \"python '$PREFIX'\/apache_module\/parser\/parser.py\"' apache_module/httpd.conf.eIDClientCore
RUN make -C apache_module
RUN for f in $CONF_FILES; do sed -i '/^APACHE_CONF_INCLUDE_FILES=\"\"/c\APACHE_CONF_INCLUDE_FILES=\"'$PREFIX'    \/apache_module\/httpd.conf.eIDClientCore\"' $f || echo Nevermind; done
