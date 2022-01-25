# A 2048-bit RSA key pair ("mykeypair.tss") is created within the TPM
# The corresponding secret key is protected by a passphrase ("123"). 
# The key pair is loaded into the TPM and the public key is exported ("mykeypair.tss")
tpm2tss-genkey -a rsa -s 2048 -p 123 mykeypair.tss
openssl rsa -engine tpm2tss -inform engine -in mykeypair.tss -pubout -outform pem -out key.pub

#
openssl req \     
    -config openssl.cnf \
    -new -x509 \  
    -engine tpm2tss \
    -key ca-root.key.tss \   
    -keyform engine \                                                              
    -new -x509 \
    -days 7300 \  
    -sha256 \     
    -extensions v3_ca \                                                            
    -out ca-root.cert

# create a CSR:
sudo openssl req -new -nodes \
    -engine tpm2tss \
    -keyform engine \
    -key mykeypair.tss \
    -subj "/C=US/ST=Washington/O=Contoso/CN=device1" \
    -out csr.pem

# ----------------------------
from here: https://github.com/tpm2-software/tpm2-pkcs11/blob/master/docs/INTEROPERABILITY.md 

# Create a token associated with a transient primary object that is compatible with tpm2-tss-engine
pid="$(sudo tpm2_ptool init --transient-parent=tss2-engine-key --path /opt/tpm2-pkcs11 | grep id | cut -d' ' -f 2-2)"

# Create a token associated with the primary object
# Note: in production set userpin and sopin to other values.
sudo tpm2_ptool addtoken --pid=$pid --sopin=1234 --userpin=1234 --label=edge2 --path /opt/tpm2-pkcs11

# link key
sudo tpm2_ptool link \
        --path /opt/tpm2-pkcs11 \
        --label "edge2" --userpin "1234" \
        --key-label="link-key" \
        mykeypair.tss

...and you get
action: link
private:
  CKA_ID: '65613430333564653936646539343261'
public:
  CKA_ID: '65613430333564653936646539343261'


#-----
from here: https://twobit.org/2019/09/29/tpm2-certificate-authority/

# generate key within the TPM
tpm2tss-genkey --alg rsa --keysize 2048 mykeypair.tss

# create a CSR:
sudo openssl req -new -nodes \
    -engine tpm2tss \
    -keyform engine \
    -key mykeypair.tss \
    -subj "/C=US/ST=Washington/O=Contoso/CN=device1" \
    -out csr.pem