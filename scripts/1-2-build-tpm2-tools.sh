#!/bin/bash
# ------------------
# build tpm2-tools
# ------------------
set -euo pipefail

sudo apt -y install uuid-dev

#VERSION=4.3.2
VERSION=5.2

cd $HOME
git clone https://github.com/tpm2-software/tpm2-tools.git
cd $HOME/tpm2-tools
git fetch --all --prune
git clean -xffd
git reset --hard
git checkout "${VERSION}"

./bootstrap

./configure

make "-j$(nproc)"
sudo make install

# remove source code
rm -rf $HOME/tpm2-tools