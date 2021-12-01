#!/bin/bash
# ------------------
# build tpm2-tools
# ------------------
set -euo pipefail

sudo apt -y install uuid-dev

cd $HOME
wget https://github.com/tpm2-software/tpm2-tools/archive/refs/tags/4.3.2.tar.gz
tar xvzf 4.3.2.tar.gz -C $HOME
cd $HOME/tpm2-tools-4.3.2

./bootstrap

./configure

make "-j$(nproc)"
sudo make install