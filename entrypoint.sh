#!/usr/bin/env bash

#Install certs
echo "installing certs"

#Write key and certs env vars to their locations
echo "$CLIENT_KEY" | base64 -d >"$CLIENT_KEY_LOCATION"
echo "$CLIENT_CRT" | base64 -d >"$CLIENT_CRT_LOCATION"
echo "$SERVER_KEY" | base64 -d >"$SERVER_KEY_LOCATION"
echo "$SERVER_CRT" | base64 -d >"$SERVER_CRT_LOCATION"
echo "$CA_CRT" | base64 -d >"$CA_CRT_LOCATION"
echo "done installing certs"

#Check if "server" or "client" mode
if [ "$1" == "server" ]; then
  /usr/sbin/freeradius -n radiusd_server -fl stdout
elif [ "$1" == "client" ]; then
  while true; do
    echo "User-Name = test@user" | radclient server auth secret
    sleep 1
  done
else
  /usr/sbin/freeradius -xxx -fl stdout
fi
