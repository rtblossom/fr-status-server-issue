#!/bin/sh

#Install certs
echo "installing certs"
echo "$VALIDATION_CA_CRT" | base64 -d >"$OR_SERVER_CA_DIR"/validation_ca.crt
c_rehash "$OR_SERVER_CA_DIR"
echo "done installing certs"

#Install validation server key and cert
echo "$SERVER_KEY" | base64 -d >"$SERVER_KEY_LOCATION"
echo "$SERVER_CRT" | base64 -d >"$SERVER_CRT_LOCATION"

#/usr/sbin/freeradius -n radiusd_hub -fl stdout -xx
/usr/sbin/freeradius -n radiusd_hub -fl $1
