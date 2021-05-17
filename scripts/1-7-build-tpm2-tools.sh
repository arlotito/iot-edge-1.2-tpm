#!/bin/bash
# ------------------
# build tpm2-tools
# ------------------
set -euo pipefail

cd ~/src/tpm2-tools

./bootstrap

./configure
make "-j$(nproc)"
sudo make install