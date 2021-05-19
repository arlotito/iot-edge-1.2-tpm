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
    -o ibmtpm1637.tar.gz \
    'https://sourceforge.net/projects/ibmswtpm2/files/ibmtpm1637.tar.gz'
tar x --one-top-level=ibmtpm1637 -f ibmtpm1637.tar.gz
cd ibmtpm1637/


# ------------------
# apply security patches
# ------------------
cp ~/iot-edge-1.2-tpm/scripts/ibm-vtpm-patches/* ~/src/ibmtpm1637
patch -p1 -i ./makefile.patch
patch -p1 -i ./ibmswtpm2-TcpServerPosix-Fix-use-of-uninitialized-value.patch
patch -p1 -i ./ibmswtpm2-NVDynamic-Fix-use-of-uninitialized-value.patch


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

