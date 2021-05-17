#!/bin/bash

# ------------------
# configure the tpm2-abmrd
# ------------------
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

sudo systemctl daemon-reload
sudo systemctl restart tpm2-abrmd

