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

# configures VTPM if any
VTPM=/etc/systemd/system/ibmswtpm2.service
if [ -f "$VTPM" ]; then
    echo "$VTPM exists. Let's configure tpm2-abrmd"
    sudo mkdir -p /etc/systemd/system/tpm2-abrmd.service.d/
    sudo tee /etc/systemd/system/tpm2-abrmd.service.d/mssim.conf <<-EOF
[Unit]
ConditionPathExistsGlob=
Requires=ibmswtpm2.service
After=ibmswtpm2.service

[Service]
ExecStart=
ExecStart=/usr/local/sbin/tpm2-abrmd --tcti=mssim
EOF
fi

# reload and restart
sudo systemctl daemon-reload
sudo systemctl restart tpm2-abrmd.service

# Verify that the service started and registered itself with dbus
dbus-send \
    --system \
    --dest=org.freedesktop.DBus --type=method_call \
    --print-reply \
    /org/freedesktop/DBus org.freedesktop.DBus.ListNames |
    (grep -q 'com.intel.tss2.Tabrmd' || :)