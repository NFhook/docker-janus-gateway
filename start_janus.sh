#!/bin/bash

echo "Start Janus Server"

if [ "$ssl_certificate" != "" -a "$ssl_certificate_key" != "" ]
then
    echo "Enable Janus SSL Port"
    #sed -i "s/https = false/https = true/g" /opt/janus/etc/janus/janus.transport.http.jcfg
    #sed -i "s/#secure_port = 8089/secure_port = 8089/g" /opt/janus/etc/janus/janus.transport.http.jcfg
    #sed -i "s?#cert_pem = \"\/path\/to\/cert.pem\"?cert_pem = \"$ssl_certificate\"?g" /opt/janus/etc/janus/janus.transport.http.jcfg
    #sed -i "s?#cert_key = \"\/path\/to\/key.pem\"?cert_key = \"$ssl_certificate_key\"?g" /opt/janus/etc/janus/janus.transport.http.jcfg
    #sed -i "s/#session_timeout = 60/session_timeout = 0/g" /opt/janus/etc/janus/janus.jcfg
    #sed -i "s/#event_loops = 8/event_loops = 8/g" /opt/janus/etc/janus/janus.jcfg
    #sed -i "s/wss = false/wss = true/g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
    #sed -i "s/#wss_port = 8989/wss_port = 8989/g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
    sed -i "s/admin_http = false/admin_http = true/g" /opt/janus/etc/janus/janus.transport.http.jcfg
    sed -i "s/#pingpong_trigger = 30/pingpong_trigger = 30/g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
    sed -i "s/#pingpong_timeout = 10/pingpong_timeout = 10/g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
    sed -i "s?#cert_pem = \"\/path\/to\/cert.pem\"?cert_pem = \"$ssl_certificate\"?g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
    sed -i "s?#cert_key = \"\/path\/to\/key.pem\"?cert_key = \"$ssl_certificate_key\"?g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
    #sed -i "s/keepalive_interval = 120/keepalive_interval = 0/g" /opt/janus/etc/janus/janus.plugin.sip.jcfg
    sed -i "s/# user_agent = \"Cool WebRTC Gateway\"/user_agent = \"RTC\"/g" /opt/janus/etc/janus/janus.plugin.sip.jcfg
fi

if [ "$stun_server" != "" ]
then
    p_stun_server="--stun-server=$stun_server"
fi
/opt/janus/bin/janus $p_stun_server
