#!/bin/bash
# ------------------
# build tpm2-tools
# ------------------

# https://github.com/tpm2-software/tpm2-tss-engine/blob/master/INSTALL.md

cd $HOME
wget https://github.com/tpm2-software/tpm2-tss-engine/archive/refs/tags/v1.1.0.tar.gz
tar xvzf v1.1.0.tar.gz -C $HOME
cd $HOME/tpm2-tss-engine-1.1.0

./bootstrap

./configure

make "-j$(nproc)"
sudo make install