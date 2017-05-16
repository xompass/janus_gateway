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
	python

### Janus ###
RUN apt-get update && apt-get install -y \
	libmicrohttpd-dev \
	libjansson-dev \
	libsofia-sip-ua-dev \
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
RUN cd /root && git clone https://github.com/meetecho/janus-gateway.git
RUN cd /root/janus-gateway && \
	./autogen.sh && \
	./configure \
		--prefix=/opt/janus \
		--disable-docs \
		--disable-plugin-videoroom \
		--disable-plugin-streaming \
		--disable-plugin-audiobridge \
		--disable-plugin-textroom \
		--disable-plugin-recordplay \
		--disable-plugin-videocall \
		--disable-plugin-voicemail \
		--disable-rabbitmq \
		--disable-mqtt \
		--disable-unix-sockets \
		--disable-data-channels && \
	make && \
	make install && \
	make configs
RUN sed -i "s/admin_http = no/admin_http = yes/g" /opt/janus/etc/janus/janus.transport.http.cfg
RUN sed -i "s/enabled = no/enabled = yes/g" /opt/janus/etc/janus/janus.eventhandler.sampleevh.cfg

### Cleaning ###
RUN apt-get clean && apt-get autoclean && apt-get autoremove

ENTRYPOINT ["/opt/janus/bin/janus"]
