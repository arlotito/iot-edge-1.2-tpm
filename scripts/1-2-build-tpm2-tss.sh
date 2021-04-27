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
id -u tss || sudo useradd --system --user-group tss
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo ldconfig