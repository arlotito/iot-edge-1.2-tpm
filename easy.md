sudo docker run -d \
    -p 8443:8443 \
    --name est-server \
    arlotito/est:1.0.6.1

openssl s_client -showcerts -connect 192.168.2.96:8443 </dev/null 2>/dev/null | openssl x509 -outform PEM >./est-ca.pem

# generate cert
cd
wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
tar xvfz EasyRSA-3.0.8.tgz
cd EasyRSA-3.0.8
export EASYRSA_HOME="${HOME}/EasyRSA-3.0.8"

cd ${EASYRSA_HOME}
./easyrsa --pki-dir=pki-est-root init-pki
./easyrsa --pki-dir=pki-est-root --batch --req-cn='myCA' build-ca nopass
./easyrsa --pki-dir=pki-est-root --batch --req-cn='est.contoso.com' gen-req est.contoso.com nopass
./easyrsa --pki-dir=pki-est-root --batch sign-req server est.contoso.com

# convert .crt to .pem
openssl x509 -in ${EASYRSA_HOME}/pki-est-root/issued/est.contoso.com.crt -out ${EASYRSA_HOME}/pki-est-root/issued/est.contoso.com.pem -outform PEM

```bash
cd
mkdir -p $HOME/est-server
cd est-server

# create the server.cfg
cat > server.cfg <<EOF
{
    "tls": {
        "certificates": "/var/lib/est/server/server-fullchain.pem",
        "private_key": "/var/lib/est/server/server.key.pem"
    },
    "allowed_hosts": []
}
EOF

sudo docker run -d \
    -p 8443:8443 \
    -v $HOME/est-server/server.cfg:/etc/est/config/server.cfg \
    -v ${EASYRSA_HOME}/pki-est-root/issued/est.contoso.com-fullchain.pem:/var/lib/est/server/server-fullchain.pem:ro \
    -v ${EASYRSA_HOME}/pki-est-root/private/est.contoso.com.key:/var/lib/est/server/server.key.pem:ro \
    --name est-server \
    arlotito/est:1.0.6.1 \
    /go/bin/estserver -config /etc/est/config/server.cfg
```


# openSSL command to download the certificate chain
openssl s_client -connect 192.168.2.96:8443 -showcerts < /dev/null \
   | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".pem"; print >out}'
cat ./cert1.pem ./cert2.pem > chain.pem
sudo cp chain.pem /etc/aziot/est-ca.pem


curl -k https://192.168.2.96:8443/.well-known/est/cacerts > response.tmp

curl https://192.168.2.96:8443/.well-known/est/cacerts -o cacerts.p7 -k

echo "-----BEGIN CERTIFICATE-----" > new
cat response.est >> new
echo "-----END CERTIFICATE-----" >> new
openssl x509 -in new -noout -text

# as per here: http://testrfc7030.com/

wget http://testrfc7030.com/dstcax3.pem
sudo cp dstcax3.pem /etc/aziot/est-ca.pem


cat > config.toml <<EOF
# DPS provisioning with X.509 certificate
[provisioning]
source = "dps"
global_endpoint = "https://global.azure-devices-provisioning.net"
id_scope = "<your DPS scope>"

[provisioning.attestation]
method = "x509"
registration_id = "my-device"
identity_cert = { method = "est", common_name = "my-device" }      

# Cert issuance via EST
# ---------------------
[cert_issuance.est]
trusted_certs = ["file:///etc/aziot/est-ca.pem"]

[cert_issuance.est.auth]
username = "username"
password = "password"

[cert_issuance.est.urls]
default = "https://testrfc7030.com:8443/.well-known/est"
EOF

sudo cp config.toml /etc/aziot/config.toml
sudo iotedge config apply