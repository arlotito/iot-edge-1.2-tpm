#!/bin/bash
# ------------------
# build tpm2-pkcs11
# ------------------
set -euo pipefail

cd ~/src/tpm2-pkcs11

# needed in case previous steps have been skipped
sudo apt-get update

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

