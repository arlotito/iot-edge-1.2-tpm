#!/bin/bash
# ------------------
# build tpm2-tss-engine
# ------------------

# https://github.com/tpm2-software/tpm2-tss-engine/blob/master/INSTALL.md

VERSION=v1.1.0

cd $HOME
git clone https://github.com/tpm2-software/tpm2-tss-engine.git
cd $HOME/tpm2-tss-engine
git fetch --all --prune
git clean -xffd
git reset --hard
git checkout "${VERSION}"

./bootstrap

./configure

make "-j$(nproc)"
sudo make install

# remove source code
rm -rf $HOME/tpm2-tss-engine