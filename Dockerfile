#libnice 0.1.20 and old 0.1.18
#sofia-sip v1.13.11 and v1.12.1
#FROM ubuntu:22.04
FROM debian:buster-slim
LABEL maintainer="NFhook <telegant@qq.com>"
USER root

ENV TZ=Asia/Shanghai    \
    ssl_certificate=""  \
    ssl_certificate_key=""  \
    stun_server=""  \
    JANUS_VERSION=v1.1.1    \
    LIBSRTP_VERSION=v2.4.2  \
    LIBNICE_VERSION=0.1.18  \
    LIBWEBSOCKETS_VERSION=v3.1.0    \
    USRSCTP_VERSION=master  \
    PAHO_MQTT_C_VERSION=v1.3.9  \
    BORINGSSL_VERSION=master    \
    LIBMICROHTTPD_VERSION=v0.9.60   \
    SOFIA_SIP_VERSION=v1.13.9    \
    ADMIN_CLI_PORT=6088

RUN set -ex; \
    \
    #sed -i s@/archive.ubuntu.com/@/cn.archive.ubuntu.com/@g /etc/apt/sources.list;	\
	#sed -i s@/security.ubuntu.com/@/cn.archive.ubuntu.com/@g /etc/apt/sources.list;	\
    sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list;   \
	apt clean;	\
    #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C;	\
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Runtime dependencies
        ca-certificates	\
        libconfig9	\
        libglib2.0-0 \
        libjansson4	\
        libopus0	\
        libogg0	\
        libmicrohttpd12	\
        # Build dependencies
        libmicrohttpd-dev	\
        libjansson-dev	\
        libssl-dev	\
        libglib2.0-dev	\
        libopus-dev	\
        libogg-dev	\
        libcurl4-openssl-dev	\
        liblua5.3-dev	\
        libconfig-dev	\
        pkg-config	\
        gengetopt	\
        libtool	\
        sudo	\
        automake	\
        autopoint   \
        texinfo \
        nodejs  \
        npm \
        git	\
        wget    \
        gzip    \
        unzip   \
        zip \
        make	\
        gtk-doc-tools	\
        ninja-build	\
        python3-pip	\
        cmake	\
        golang-go	\
        build-essential	\
        autoconf	\
        duktape-dev	\
        libavcodec-dev	\
        libavformat-dev	\
        libavutil-dev	\
        libcollection-dev	\
        libevent-dev	\
        libgnutls28-dev	\
        libini-config-dev	\
        libmount-dev	\
        libnanomsg-dev	\
        librabbitmq-dev	\
        libsofia-sip-ua-dev	\
        libvorbis-dev	\
        openssl	\
        libgupnp-igd-1.0-4  \
        #additional dependencies
        #libnice-dev	\
        #libusrsctp-dev	\
        #libwebsockets-dev	\
    ;	\
    #sudo pip3 install -Iv wheel meson==0.54.3;	\
    sudo pip3 install meson;    \
    mkdir /build; \
    git config --global http.proxy 'http://10.10.18.125:7890';  \
    git config --global https.proxy 'http://10.10.18.125:7890'; \
    export GO111MODULE=on;  \
    export GOPROXY=https://goproxy.cn;  \
    git clone --branch $JANUS_VERSION https://github.com/meetecho/janus-gateway.git /build/janus-gateway; \
    git clone --branch $LIBSRTP_VERSION https://github.com/cisco/libsrtp.git /build/libsrtp; \
    git clone --branch $LIBNICE_VERSION https://gitlab.freedesktop.org/libnice/libnice.git /build/libnice; \
    git clone --branch $USRSCTP_VERSION https://github.com/sctplab/usrsctp /build/usrsctp; \
    git clone --branch $LIBWEBSOCKETS_VERSION https://libwebsockets.org/repo/libwebsockets /build/libwebsockets; \
    git clone --branch $PAHO_MQTT_C_VERSION https://github.com/eclipse/paho.mqtt.c /build/paho.mqtt.c;	\
    git clone --branch $BORINGSSL_VERSION https://github.com/google/boringssl /build/boringssl;	\
    git clone --branch $LIBMICROHTTPD_VERSION https://git.gnunet.org/libmicrohttpd /build/libmicrohttpd;    \
    git clone --branch $SOFIA_SIP_VERSION https://github.com/freeswitch/sofia-sip /build/sofia-sip; \
    \
    #cd /build;  \
    #wget https://ixpeering.dl.sourceforge.net/project/sofia-sip/sofia-sip/1.12.11/sofia-sip-1.12.11.tar.gz; \
    #tar -zxvf sofia-sip-1.12.11.tar.gz;  \
    #cd sofia-sip-1.12.11;   \
    #./configure --prefix=/usr CFLAGS=-fno-aggressive-loop-optimizations;    \
    cd /build/sofia-sip;    \
    sh autogen.sh;  \
    ./configure;    \
    make;   \
    make install;   \
    \
    cd /build/libmicrohttpd;    \
    autoreconf -fi; \
    ./configure;    \
    make;   \
    make install;   \
    \
    cd /build/boringssl;	\
    git reset --hard c7db3232c397aa3feb1d474d63a1c4dd674b6349;    \
    sed -i s/" -Werror"//g CMakeLists.txt;	\
    mkdir -p build;	\
    cd build;	\
    cmake -DCMAKE_CXX_FLAGS="-lrt" ..;	\
    make;	\
    cd ..;	\
    sudo mkdir -p /opt/boringssl;	\
    sudo cp -R include /opt/boringssl/;	\
    sudo mkdir -p /opt/boringssl/lib;	\
    sudo cp build/ssl/libssl.a /opt/boringssl/lib/;	\
    sudo cp build/crypto/libcrypto.a /opt/boringssl/lib/;	\
	\
    cd /build/libnice; \
    #meson setup -Dprefix=/usr -Dlibdir=lib -Dc_args="-Wno-cast-align" -Ddebug=false -Doptimization=0 -Dexamples=disabled -Dgtk_doc=disabled -Dgupnp=disabled -Dgstreamer=disabled -Dtests=disabled build;	\
    meson build; \
    ninja -C build;	\
    sudo ninja -C build install;	\
    \
    cd /build/libsrtp; \
    ./configure --prefix=/usr --enable-openssl --disable-aes-gcm; \
    make shared_library;    \
    sudo make install; \
    \
    cd /build/usrsctp; \
    git reset --hard 1c9c82fbe3582ed7c474ba4326e5929d12584005;  \
    ./bootstrap; \
    ./configure;    \
    #./configure --prefix=/usr --disable-static --disable-debug --disable-programs --disable-inet --disable-inet6;	\
    make;	\
    make install;	\
	\
    cd /build/libwebsockets; \
    mkdir build; \
    cd build; \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DLWS_WITH_STATIC=OFF -DLWS_WITHOUT_CLIENT=ON -DLWS_WITHOUT_TESTAPPS=ON -DLWS_WITHOUT_TEST_SERVER=ON -DLWS_WITH_HTTP2=OFF ..;	\
    make;	\
    make install;	\
	\
    cd /build/paho.mqtt.c;	\
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DPAHO_WITH_SSL=TRUE -DPAHO_BUILD_SAMPLES=FALSE -DPAHO_BUILD_DOCUMENTATION=FALSE;	\
    make;	\
    make install;	\
	\
    cd /build/janus-gateway; \
    sh autogen.sh;	\
    ./configure --prefix=/opt/janus --enable-post-processing --enable-boringssl --enable-data-channels --enable-rabbitmq --enable-mqtt --enable-unix-sockets --enable-dtls-settimeout \
    --enable-plugin-echotest --enable-plugin-recordplay --enable-plugin-sip --enable-plugin-videocall --enable-plugin-voicemail --enable-plugin-textroom --enable-rest \
    --enable-turn-rest-api --enable-plugin-audiobridge --enable-plugin-nosip --enable-websockets-event-handler --enable-rabbitmq-event-handler --enable-mqtt-event-handler \
    --enable-sample-event-handler --enable-all-handlers --enable-json-logger	\
    --enable-javascript-es-module;	\
    make;	\
    make install;	\
    make configs;	\
    cd /; \
    rm -rf /build; \
    \
    pip3 uninstall -y meson; \
    rm -rf /root/.cache/pip; \
    apt-get purge -y --autoremove \
        libmicrohttpd-dev \
        liblua5.3-dev \
        libtool \
        automake    \
        autopoint   \
        texinfo \
        nodejs  \
        npm \
        git \
        wget    \
        gzip    \
        unzip   \
        zip \
        make    \
        gtk-doc-tools   \
        ninja-build \
        python3-pip \
        cmake   \
        pkg-config \
        gengetopt \
        libtool \
        golang-go   \
        git \
        nodejs  \
        npm \
        make \
        build-essential --allow-remove-essential    \
    ; \
    apt-get install -y curl iproute2; \
    rm -rf /var/lib/apt/lists/*;

ADD start_janus.sh janus-admin-cli /
RUN chmod +x start_janus.sh janus-admin-cli
SHELL    ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  ./janus-admin-cli -a $(ip route get 8.8.8.8 | head -n +1 | tr -s " " | cut -d " " -f 7) -p $ADMIN_CLI_PORT -t 1 -r ping |grep -q  "pong" || exit 1
CMD ["./start_janus.sh"]
