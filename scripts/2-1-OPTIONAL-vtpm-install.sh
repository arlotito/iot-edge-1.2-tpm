#!/bin/bash
sudo apt-get update


# ------------------
# download the source code
# ------------------
sudo apt install \
    curl gcc make patch tar \
    libssl-dev

mkdir -p ~/src
cd ~/src

curl -L \
    -o ibmtpm.tar.gz \
    'https://sourceforge.net/projects/ibmswtpm2/files/ibmtpm1661.tar.gz'
tar x --one-top-level=ibmtpm -f ibmtpm.tar.gz
cd ibmtpm/

# ------------------
# build and install
# ------------------
cd src/
make "-j$(nproc)"

mkdir -p /usr/local/bin
sudo cp ./tpm_server /usr/local/bin/tpm_server

sudo mkdir -p /var/lib/ibmswtpm2
sudo chown "$(id -u tss):$(id -g tss)" /var/lib/ibmswtpm2


sudo mkdir -p /etc/systemd/system/
sudo tee /etc/systemd/system/ibmswtpm2.service <<-EOF
[Unit]
Description=IBM's Software TPM 2.0

[Service]
ExecStart=/usr/local/bin/tpm_server
WorkingDirectory=/var/lib/ibmswtpm2
User=tss
EOF
sudo systemctl daemon-reload
sudo systemctl start ibmswtpm2

rm -rf ~/src/ibmtpm

