#!/bin/bash

# ------------------
# set env variables
# ------------------

# Variables to identify and log in to the PKCS#11 token
TOKEN='edge'
TOKEN_PARAM="token=$TOKEN"
PIN='1234'
PIN_SUFFIX="?pin-value=$PIN"

# ------------------
# clear the TPM
# ------------------
sudo tpm2_clear

# ------------------
#initialize the PKCS11 store
# ------------------

sudo mkdir -p /opt/tpm2-pkcs11

# tpm2_ptool requires Python 3 >= 3.7 and expects `python3`
# to be that version by default.
#
# If your distro has python3.7 or higher at a different path,
# like how Ubuntu 18.04 has `python3.7`, then set
# the `PYTHON_INTERPRETER` env var.
#
# export PYTHON_INTERPRETER=python3.7
cd ~/src/tpm2-pkcs11/tools
sudo ./tpm2_ptool init --primary-auth '1234' --path /opt/tpm2-pkcs11
sudo ./tpm2_ptool addtoken --path /opt/tpm2-pkcs11 \
        --sopin "so$PIN" --userpin "$PIN" \
        --label "$TOKEN" --pid '1'

#NOTE: from the tpm2_ptool help:
#       --path PATH     The location of the store directory. If specified, the
#                       directory MUST exist. If not specified performs a
#                       search by looking at environment variable
#                       TPM2_PKCS11_STORE and if not set then /etc/tpm2_pkcs11
#                       and if not found or no write access, then
#                       $HOME/.tpm2_pkcs11 and if not found or cannot be
#                       created, then defaults to using the current working
#                       directory.

# now that iot edge is installed and user aziotks exisists, we can fix permissions
sudo chown "aziotks:aziotks" /opt/tpm2-pkcs11 -R
sudo chmod 0700 /opt/tpm2-pkcs11