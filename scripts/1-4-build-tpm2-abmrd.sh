#!/bin/bash
# ------------------
# build tpm2-abrmd
# ------------------
set -euo pipefail

cd ~/src/tpm2-abrmd

./bootstrap

./configure \
    --with-dbuspolicydir=/etc/dbus-1/system.d \
    --with-systemdsystemunitdir=/lib/systemd/system \
    --with-systemdpresetdir=/lib/systemd/system-preset \
    --datarootdir=/usr/share
make "-j$(nproc)"
sudo make install
sudo ldconfig
sudo pkill -HUP dbus-daemon
sudo systemctl daemon-reload
sudo systemctl enable tpm2-abrmd.service
sudo systemctl restart tpm2-abrmd.service

# Verify that the service started and registered itself with dbus
dbus-send \
    --system \
    --dest=org.freedesktop.DBus --type=method_call \
    --print-reply \
    /org/freedesktop/DBus org.freedesktop.DBus.ListNames |
    (grep -q 'com.intel.tss2.Tabrmd' || :)