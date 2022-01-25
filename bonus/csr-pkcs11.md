
sudo apt-get install libengine-pkcs11-openssl -y




cd
cat > pkcs11-engine.conf <<EOF
openssl_conf = openssl_def

[openssl_def]
engines = engine_section

[engine_section]
pkcs11 = pkcs11_section

[pkcs11_section]
engine_id = pkcs11

# This is the path to engine that openssl loads
dynamic_path = /usr/lib/arm-linux-gnueabihf/engines-1.1/pkcs11.so

# this is the path to the pkcs11 implementation that the pkcs11 engine loads
MODULE_PATH = /usr/local/lib/libtpm2_pkcs11.so

init = 0
EOF

cat > tpm2tss-engine.conf <<EOF
openssl_conf = openssl_init

[openssl_init]
engines = engine_section

[engine_section]
tpm2 = tpm2_section

[tpm2_section]
engine_id = tpm2tss

# This is the path to engine that openssl loads
dynamic_path = /usr/lib/arm-linux-gnueabihf/engines-1.1/libtpm2tss.so

# this is the path to the pkcs11 implementation that the pkcs11 engine loads
MODULE_PATH = /usr/local/lib/libtpm2_pkcs11.so

init = 0
EOF

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

# create CSR:
sudo openssl req -new -nodes \
    -engine tpm2tss \
    -keyform engine \
    -key "pkcs11:token=edge;object=myrsa;type=private" \
    -subj "/C=US/ST=Washington/O=Contoso/CN=device1" \
    -out csr.pem