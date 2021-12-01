#!/bin/bash
# ------------------
# build tpm2-pkcs11
# ------------------


sudo apt install libsqlite3-dev libyaml-dev python3.7-dev libffi-dev -y

# https://github.com/tpm2-software/tpm2-pkcs11/blob/master/docs/INSTALL.md

VERSION=1.6.0
#VERSION=1.7.0

cd $HOME
git clone https://github.com/tpm2-software/tpm2-pkcs11.git
cd $HOME/tpm2-pkcs11
git fetch --all --prune
git clean -xffd
git reset --hard
git checkout "${VERSION}"


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
cd $HOME/tpm2-pkcs11/tools
sudo pip3 install .

# remove source code
rm -rf $HOME/tpm2-pkcs11

