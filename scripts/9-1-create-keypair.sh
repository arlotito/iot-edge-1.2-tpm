#!/bin/bash
export TPM2_PKCS11_STORE='/opt/tpm2-pkcs11'

# create the 'rsakeypair'
PKCS11_LIB_PATH='/usr/local/lib/libtpm2_pkcs11.so'
PIN=1234

sudo pkcs11-tool --module $PKCS11_LIB_PATH --label="rsakeypair" --login --pin $PIN --keypairgen --usage-sign
