# install the pkcs11 engine
If not done already, install the pkcs11 engine:
```bash
cd ~/iot-edge-1.2-tpm/scripts
./9-2-openssl-x86.sh

# test the engine
export OPENSSL_CONF=/home/arlotito/tpm2-pkcs11.openssl.conf
openssl engine pkcs11 -t
```

# create CSR
```bash
# switch to root
sudo su

# export some vars
export TPM2_PKCS11_STORE='/opt/tpm2-pkcs11'
export PKCS11_LIB_PATH='/usr/local/lib/libtpm2_pkcs11.so'
export OPENSSL_CONF=/home/arlotito/tpm2-pkcs11.openssl.conf

# create the 'rsakeypair'
sudo pkcs11-tool --module $PKCS11_LIB_PATH --label="rsakeypair" --login --keypairgen --usage-sign

# optionally check the store
sudo pkcs11-tool --module "$PKCS11_LIB_PATH" -IOT

# create a CSR
openssl req -new -nodes -engine pkcs11 -keyform engine \
    -key "pkcs11:token=edge;object=rsakeypair;type=private" \
    -subj "/C=US/ST=Somewhere/L=Somewhere/O=company x/OU=iot/CN=device1" \
    -out csr.pem
```
