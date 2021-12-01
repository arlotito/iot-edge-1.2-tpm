#!/bin/bash
# ------------------
# build tpm2-tss
# ------------------
set -euo pipefail

cd

# as per https://github.com/tpm2-software/tpm2-tss/blob/master/INSTALL.md
sudo apt -y install \
  autoconf-archive \
  libcmocka0 \
  libcmocka-dev \
  procps \
  iproute2 \
  build-essential \
  git \
  pkg-config \
  gcc \
  libtool \
  automake \
  libssl-dev \
  uthash-dev \
  autoconf \
  doxygen \
  libjson-c-dev \
  libini-config-dev \
  libcurl4-openssl-dev

# raspberry
sudo apt install acl -y

cd $HOME
wget https://github.com/tpm2-software/tpm2-tss/archive/refs/tags/3.1.0.tar.gz 
tar xvzf 3.1.0.tar.gz -C $HOME
cd $HOME/tpm2-tss-3.1.0

./bootstrap

./configure \
    --with-udevrulesdir=/etc/udev/rules.d \
    --with-udevrulesprefix=70-

make "-j$(nproc)"
sudo make install

# add tss if does not exist
if id "tss" &>/dev/null; then
    echo "user tss already exists"
else
    echo "adding user tss"
    sudo useradd --system --user-group tss
fi

sudo udevadm control --reload-rules && sudo udevadm trigger
sudo ldconfig