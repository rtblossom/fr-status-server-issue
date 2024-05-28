#FROM freeradius/freeradius-server:3.0.26
FROM freeradius/freeradius-server:3.2.3

#RUN apt-get update && \
#DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
#curl
#
##From https://networkradius.com/packages/#fr30-ubuntu-jammy
#RUN install -d -o root -g root -m 0755 /etc/apt/keyrings && \
#curl -s 'https://packages.networkradius.com/pgp/packages%40networkradius.com' | \
#tee /etc/apt/keyrings/packages.networkradius.com.asc > /dev/null && \
#printf 'Package: /freeradius/\nPin: origin "packages.networkradius.com"\nPin-Priority: 999\n' | \
#tee /etc/apt/preferences.d/networkradius > /dev/null && \
#echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.networkradius.com.asc] http://packages.networkradius.com/freeradius-3.0/ubuntu/jammy jammy main" | \
#tee /etc/apt/sources.list.d/networkradius.list > /dev/null
#
#RUN apt-get update && \
#DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
#freeradius

#RUN apt-get update && \

#Define base FreeRADIUS directory
ENV FRBASEDIR=/etc/freeradius

#Define directory to all certs and keys for this service
ENV PKIDIR=/pki

#Define cert and key locations
ENV CLIENT_KEY_LOCATION=$PKIDIR/client.key
ENV CLIENT_CRT_LOCATION=$PKIDIR/client.crt
ENV SERVER_KEY_LOCATION=$PKIDIR/server.key
ENV SERVER_CRT_LOCATION=$PKIDIR/server.crt

#Define server side subdirectories for RadSec client validation
ENV CA_DIR=$PKIDIR/ca

#Disable the defaults that need to be disabled.
RUN \
rm $FRBASEDIR/sites-enabled/default && \
rm $FRBASEDIR/sites-enabled/inner-tunnel && \
rm $FRBASEDIR/mods-enabled/eap

#Create directories for storing PKI
RUN \
mkdir $PKIDIR && \
mkdir $CA_DIR

ENV CA_CRT_LOCATION=$CA_DIR/ca.crt

#Copy and enable configs.
COPY config/ $FRBASEDIR/
RUN \
ln -fs $FRBASEDIR/mods-available/linelog $FRBASEDIR/mods-enabled/linelog && \
#Enable status server so we can query statistics
ln -fs $FRBASEDIR/sites-available/status $FRBASEDIR/sites-enabled/status && \
ln -fs $FRBASEDIR/sites-available/openroaming $FRBASEDIR/sites-enabled/openroaming && \
sed -i 's/wait = no/wait = yes/' $FRBASEDIR/mods-available/exec

#Copy scripts
COPY entrypoint.sh /

EXPOSE 2083/tcp
CMD ["sh", "/entrypoint.sh"]

