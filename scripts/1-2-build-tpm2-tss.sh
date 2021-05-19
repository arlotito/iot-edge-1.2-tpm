#!/bin/bash
# ------------------
# build tpm2-tss
# ------------------
set -euo pipefail

cd ~/src/tpm2-tss

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

sudo udevadm control --reload-rules
sudo udevadm trigger
sudo ldconfig