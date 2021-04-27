#!/bin/bash
set -euo pipefail

sudo apt-get update

# Install build dependencies
sudo apt install -y \
    git \
    autoconf automake doxygen libtool \
    libcurl4-openssl-dev libdbus-1-dev libgcrypt-dev \
    libglib2.0-dev libjson-c-dev libsqlite3-dev libssl-dev \
    python3-cryptography python3-pyasn1-modules python3-yaml \
    uuid-dev libyaml-dev

# Create base source directory
mkdir -p ~/src

# Define the version numbers
#
# Refs:
# - https://tpm2-software.github.io/versions/#tpm2-tools
# - https://github.com/tpm2-software/tpm2-abrmd/releases
# - https://github.com/tpm2-software/tpm2-pkcs11/releases
# - https://github.com/tpm2-software/tpm2-tools/releases
# - https://github.com/tpm2-software/tpm2-tss/releases

declare -A checkouts

checkouts['tpm2-abrmd']='2.4.0'
checkouts['tpm2-pkcs11']='1.5.0'
checkouts['tpm2-tools']='5.0'
checkouts['tpm2-tss']='3.0.3'


# Download `autoconf-2019.01.06` and extract it.
#
# There is a newer autoconfig-archive, but the tpm2-* autoconf files have
# hard-coded things for 2019_01_06

if ! [ -f ~/src/autoconf-archive-2019.01.06.tar.gz ]; then
    curl -L \
        -o ~/src/autoconf-archive-2019.01.06.tar.gz \
        'https://github.com/autoconf-archive/autoconf-archive/archive/v2019.01.06.tar.gz'
fi
if ! [ -d ~/src/autoconf-archive-2019.01.06 ]; then
    (cd ~/src/ && tar xf ~/src/autoconf-archive-2019.01.06.tar.gz)
fi


# Clone and bootstrap the repositories

for d in "${!checkouts[@]}"; do
    (
        set -euo pipefail

        if ! [ -d ~/src/"$d" ]; then
            git clone "https://github.com/tpm2-software/$d" ~/src/"$d"
        fi
        cd ~/src/"$d"

        git fetch --all --prune
        git clean -xffd
        git reset --hard
        git checkout "${checkouts["$d"]}"

        cp -R ~/src/autoconf-archive-2019.01.06/m4 .

        #ART: removed from here and done when building each single library
        # ./bootstrap -I m4
    ) & :
done

wait $(jobs -pr)