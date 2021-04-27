#!/bin/bash

# install the engine
sudo apt-get install libengine-pkcs11-openssl -y

# copy the engine conf to user's home
cp ./tpm2-pkcs11.openssl.conf ~/tpm2-pkcs11.openssl.conf

