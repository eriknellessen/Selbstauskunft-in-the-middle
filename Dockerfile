FROM debian:buster-20220125

#install deb packages
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y build-essential autoconf libtool pkg-config python3 python3-crypto python3-pyscard help2man libpcsclite-dev apache2 apache2-dev subversion libwxgtk3.0-gtk3-dev libcrypto++-dev expat git gengetopt libqrencode-dev wget pcscd pcsc-tools net-tools tshark vim

RUN git clone https://gitlab.com/eriknellessen/Selbstauskunft-in-the-middle.git
WORKDIR /Selbstauskunft-in-the-middle
RUN git checkout 5671f7d5bc0835033e3df10bb502215ed87fe734

ENV PREFIX=/Selbstauskunft-in-the-middle/
ENV CONF_FILES="/etc/sysconfig/apache2 /etc/apache2/apache2.conf"
RUN git submodule update --init --recursive
WORKDIR /Selbstauskunft-in-the-middle/vsmartcard/virtualsmartcard
RUN autoreconf --verbose --install
RUN ./configure --sysconfdir=/etc PYTHON="`which python3`"
RUN make
RUN make install
WORKDIR /Selbstauskunft-in-the-middle/eIDClientCore
ENV PREFIX=/Selbstauskunft-in-the-middle/eIDClientCore
RUN make asn1c
RUN make openssl
RUN make libcurl
RUN make eIDClient
WORKDIR /Selbstauskunft-in-the-middle
ENV PREFIX=/Selbstauskunft-in-the-middle/
RUN sed -i '/eIDClientCoreEIDCCBinaryPath \"\"/c\eIDClientCoreEIDCCBinaryPath \"'$PREFIX'\/eIDClientCore\/bin\/Start_Testcase --testcase=AutentApp\"' apache_module/httpd.conf.eIDClientCore
RUN sed -i '/eIDClientCoreParserCommand \"\"/c\eIDClientCoreParserCommand \"python '$PREFIX'\/apache_module\/parser\/parser.py\"' apache_module/httpd.conf.eIDClientCore
RUN sed -i '/eIDClientCoreEIDCCLibraryPath \"\"/c\eIDClientCoreEIDCCLibraryPath \"'$PREFIX'\/eIDClientCore\/lib/\"' apache_module/httpd.conf.eIDClientCore
RUN make -C apache_module
RUN for f in $CONF_FILES; do echo "Include $PREFIX/apache_module/httpd.conf.eIDClientCore" >> $f || echo Nevermind; done
RUN sed -i 's/Listen 80/Listen 4444/g' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost *:80>/<VirtualHost *:4444>/g' /etc/apache2/sites-enabled/000-default.conf
COPY apache_module/selbstauskunft-in-the-middle-example.html /var/www/html/index.html

COPY run.sh /usr/local/bin/run.sh
RUN chmod 755 /usr/local/bin/run.sh
CMD ["/usr/local/bin/run.sh"]
