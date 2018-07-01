FROM debian:9

LABEL maintainer="ssskip"

WORKDIR /janus

RUN apt-get update -y \
    && apt-get upgrade -y

RUN apt-get install -y \
    build-essential \
    libmicrohttpd-dev \
    libjansson-dev \
    libnice-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    liblua5.3-dev \
    libopus-dev \
    libogg-dev \
    libcurl4-openssl-dev \
    libini-config-dev \
    libcollection-dev \
    pkg-config \
    gengetopt \
    libtool \
    autotools-dev \
    automake

RUN apt-get install -y \
    sudo \
    make \
    git \
    cmake


RUN git clone https://github.com/cisco/libsrtp.git \
    && cd libsrtp \
    && git checkout v2.1.0 \
    && ./configure --prefix=/usr --enable-openssl \
    && make shared_library \
    && sudo make install

RUN git clone https://github.com/sctplab/usrsctp \
    && cd usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install

RUN git clone https://github.com/warmcat/libwebsockets.git \
    && cd libwebsockets \
    && git checkout v3.0.0 \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. \
    && make \
    && sudo make install

RUN git clone https://github.com/meetecho/janus-gateway.git \
    && cd janus-gateway \
    && sh autogen.sh \
    && ./configure --prefix=/opt/janus --disable-rabbitmq --disable-mqtt \
    && make CFLAGS='-std=c99' \
    && make install \
    && make configs

RUN cp -rp /janus/janus-gateway/certs /opt/janus/share/janus

COPY conf/*.cfg /opt/janus/etc/janus/
VOLUME /opt/janus/etc/

EXPOSE 7088 8088 8188 8089

EXPOSE 32000-32200/udp

CMD [ "sh","-c","/opt/janus/bin/janus","-1","${PUB_IP}" ]