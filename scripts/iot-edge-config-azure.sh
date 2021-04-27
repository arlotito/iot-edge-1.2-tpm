#!/bin/bash

DEVICE_ID=$1
DPS_SCOPEID=$2
EST_HOSTNAME=$3
EST_USERNAME=$4
EST_PASSWORD=$5

cd "$(dirname "$0")"

echo downloading the EST CA cert from $EST_HOSTNAME
openssl s_client -showcerts -connect $EST_HOSTNAME </dev/null 2>/dev/null|openssl x509 -outform PEM >est-ca.pem
sudo mv est-ca.pem /etc/aziot/

echo
echo applying configuration to iot edge...
export DEVICE_ID=$DEVICE_ID
export DPS_SCOPEID=$DPS_SCOPEID
export EST_URL=https://$EST_HOSTNAME/.well-known/est
export EST_USERNAME=$EST_USERNAME
export EST_PASSWORD=$EST_PASSWORD
cat config.toml.est.template | envsubst > config.toml.est.expanded

sudo cp config.toml.est.expanded /etc/aziot/config.toml
sudo iotedge config apply
