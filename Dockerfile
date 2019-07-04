FROM     ubuntu:16.04

### build tools ###
RUN apt-get update && apt-get install -y \
	build-essential \
	autoconf \
	automake \
	cmake

### Utils ###
RUN apt-get update && apt-get install -y \
	vim \
	curl \
	psmisc \
	nano \
	git \
	wget \
	unzip \
	python \
	libconfig-dev

###sipre plugin (dev stage)###
#RUN wget http://creytiv.com/pub/re-0.5.3.tar.gz && tar xvf re-0.5.3.tar.gz && \
#	cd re-0.5.3 && \
#	wget https://raw.githubusercontent.com/alfredh/patches/master/re-sip-trace.patch && \
#	ls && \
#	make clean && \
#       patch -p0 -u < re-sip-trace.patch && \
#	make && \
#	make install
#	nm /usr/local/lib/libre.so | grep tls_alloc

### Janus ###
RUN apt-get update && apt-get install -y \
	libmicrohttpd-dev \
	libjansson-dev \
	#libsofia-sip-ua-dev \
	libglib2.0-dev \
	libevent-dev \
	libtool \
	gengetopt \
	libssl-dev \
	openssl \
	libcurl4-openssl-dev
RUN cd /root && wget https://nice.freedesktop.org/releases/libnice-0.1.13.tar.gz && \
	tar xvf libnice-0.1.13.tar.gz && \
	cd libnice-0.1.13 && \
	./configure --prefix=/usr && \
	make && \
	make install
RUN cd /root && git clone git://git.libwebsockets.org/libwebsockets && \
	cd libwebsockets && \
	git checkout v2.0.2 && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. && \
	make && \
	make install
RUN cd /root && wget https://github.com/cisco/libsrtp/archive/v2.0.0.tar.gz -O libsrtp-2.0.0.tar.gz && \
	tar xfv libsrtp-2.0.0.tar.gz && \
	cd /root/libsrtp-2.0.0 && \
	./configure --prefix=/usr --enable-openssl && \
	make shared_library && \
	make install
RUN cd /root && wget http://conf.meetecho.com/sofiasip/sofia-sip-1.12.11.tar.gz && \
	tar xfv sofia-sip-1.12.11.tar.gz && \
	cd sofia-sip-1.12.11 && \
	wget http://conf.meetecho.com/sofiasip/0001-fix-undefined-behaviour.patch && \
	wget http://conf.meetecho.com/sofiasip/sofiasip-semicolon-authfix.diff && \
	patch -p1 -u < 0001-fix-undefined-behaviour.patch && \
	patch -p1 -u < sofiasip-semicolon-authfix.diff && \
	./configure --prefix=/usr && \
	make && make install
# datachannel build
#RUN cd / && git clone https://github.com/sctplab/usrsctp.git && cd /usrsctp && \
#    git checkout origin/master && git reset --hard 1c9c82fbe3582ed7c474ba4326e5929d12584005 && \
#    ./bootstrap && \
#    ./configure && \
#    make && make install
RUN cd /root && git clone https://github.com/meetecho/janus-gateway.git
RUN cd /root/janus-gateway && \
	./autogen.sh && \
	./configure \
		--prefix=/opt/janus \
		--disable-docs \
		--disable-plugin-audiobridge \
		--disable-plugin-textroom \
		--disable-plugin-recordplay \
		--disable-plugin-videocall \
		--disable-plugin-voicemail \
		--disable-rabbitmq \
		--disable-mqtt \
		--disable-unix-sockets && \
	make && \
	make install && \
	make configs
RUN sed -i "s/admin_http = no/admin_http = yes/g" /opt/janus/etc/janus/janus.transport.http.jcfg
RUN sed -i "s/https = no/https = yes/g" /opt/janus/etc/janus/janus.transport.http.jcfg
RUN sed -i "s/;secure_port = 8089/secure_port = 8089/g" /opt/janus/etc/janus/janus.transport.http.jcfg
RUN sed -i "s/wss = no/wss = yes/g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
RUN sed -i "s/;wss_port = 8989/wss_port = 8989/g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
RUN sed -i "s/enabled = no/enabled = yes/g" /opt/janus/etc/janus/janus.eventhandler.sampleevh.jcfg
RUN sed -i "s\^backend.*path$\backend = http://janus.click2vox.io:7777\g" /opt/janus/etc/janus/janus.eventhandler.sampleevh.jcfg
#RUN sed -i s/grouping = yes/grouping = no/g /opt/janus/etc/janus/janus.eventhandler.sampleevh.jcfg
RUN sed -i "s/behind_nat = no/behind_nat = yes/g" /opt/janus/etc/janus/janus.plugin.sip.jcfg
RUN sed -i "s/;rtp_port_range = 20000-40000/rtp_port_range = 10000-10200/g" /opt/janus/etc/janus/janus.jcfg

### Cleaning ###
RUN apt-get clean && apt-get autoclean && apt-get autoremove

ENTRYPOINT ["/opt/janus/bin/janus"]
