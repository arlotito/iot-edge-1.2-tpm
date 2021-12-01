#!/bin/bash
# ------------------
# build tpm2-pkcs11
# ------------------


sudo apt install libsqlite3-dev libyaml-dev -y

# https://github.com/tpm2-software/tpm2-pkcs11/blob/master/docs/INSTALL.md

cd $HOME
wget https://github.com/tpm2-software/tpm2-pkcs11/archive/refs/tags/1.6.0.tar.gz
tar xvzf 1.6.0.tar.gz -C $HOME
cd $HOME/tpm2-pkcs11-1.6.0


# removes /opt/tpm2-pkcs11 if any
sudo rm -rf /opt/tpm2-pkcs11

# The `tpm2-pkcs11` library uses a filesystem directory to store
# wrapped keys. Ensure this directory is readable and writable by
# the user you'll be running `aziot-keyd` (i.e. aziotks) as,
# not just root.
sudo mkdir /opt/tpm2-pkcs11

# NOTE: cannot set aziotks user now, as iot edge may be not installed yet.
# will do it later in step 5.

./bootstrap

# --enable-debug=!yes is needed to disable assert() in
# CKR_FUNCTION_NOT_SUPPORTED-returning unimplemented functions.
./configure \
    --enable-debug=info \
    --enable-esapi-session-manage-flags \
    --with-storedir=/opt/tpm2-pkcs11

make "-j$(nproc)"
sudo make install

# ------------------
# install missing package
# ------------------
# install pip
sudo apt install python3-pip -y

# install cffi
pip3 install -U cffi

# install tpm2-ptools
cd $HOME/tpm2-pkcs11-1.6.0/tools
sudo pip3 install .

