#!/bin/bash
echo This script will configure your IoT Edge to provision via DPS using a device identity certificate dynamically issued by an EST CA.
echo The PKCS11/TPM is used to securely store keys.
echo
echo DPS provisioning
echo --------------------------------
echo Registration ID? ex. my-device-1
read DEVICE_ID
echo
echo Scope ID? ex. 0ne00112233
read DPS_SCOPEID
echo

echo
echo EST configuration
echo --------------------------------
echo EST hostname:port? ex. id.myest.net:443
read EST_HOSTNAME
echo
echo Username? ex. username
read EST_USERNAME
echo
echo
echo Password? ex. password
read EST_PASSWORD
echo

echo
echo downloading the EST CA cert from $EST_HOSTNAME
openssl s_client -showcerts -connect $EST_HOSTNAME </dev/null 2>/dev/null|openssl x509 -outform PEM >./est-ca.pem
sudo cp ./est-ca.pem /etc/aziot/
rm ./est-ca.pem

echo
echo applying configuration to iot edge...
export DEVICE_ID=$DEVICE_ID
export DPS_SCOPEID=$DPS_SCOPEID
export EST_URL=https://$EST_HOSTNAME/.well-known/est
export EST_USERNAME=$EST_USERNAME
export EST_PASSWORD=$EST_PASSWORD
cat ./config.toml.est.template | envsubst > ./config.toml.est.expanded

sudo cp ./config.toml.est.expanded /etc/aziot/config.toml
sudo iotedge config apply
