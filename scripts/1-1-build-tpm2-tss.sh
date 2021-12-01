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

VERSION=3.1.0

cd $HOME
git clone https://github.com/tpm2-software/tpm2-tss.git
cd $HOME/tpm2-tss
git fetch --all --prune
git clean -xffd
git reset --hard
git checkout "${VERSION}"

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

# remove source code
rm -rf $HOME/tpm2-tss