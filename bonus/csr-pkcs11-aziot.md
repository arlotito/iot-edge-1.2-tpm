sudo apt-get install libengine-pkcs11-openssl -y

export OPENSSL_CONF="/home/arlotito/pkcs11-engine.conf"

export TPM2_PKCS11_STORE='/opt/tpm2-pkcs11'
export PKCS11_LIB_PATH='/usr/local/lib/libtpm2_pkcs11.so'

sudo tpm2_clear
sudo rm -rf /opt/tpm2-pkcs11/
sudo mkdir -p /opt/tpm2-pkcs11
sudo tpm2_ptool init --primary-auth '1234' --path /opt/tpm2-pkcs11
sudo tpm2_ptool addtoken --path /opt/tpm2-pkcs11 \
        --sopin "1234" --userpin "1234" \
        --label "edge" --pid '1'

sudo pkcs11-tool --module $PKCS11_LIB_PATH --label="myrsa" --login --keypairgen --usage-sign


---- THIS DOES NOT WORK


# create CSR:
sudo openssl req -new -nodes \
    -engine aziot_keys \
    -keyform engine \
    -key "pkcs11:token=edge;object=myrsa;type=private" \
    -subj "/C=US/ST=Washington/O=Contoso/CN=device1" \
    -out csr.pem

# create CSR:
sudo openssl req -new -nodes \
    -engine aziot_keys \
    -keyform engine \
    -key slot_0-label_myrsa \
    -subj "/C=US/ST=Washington/O=Contoso/CN=device1" \
    -out csr.pem