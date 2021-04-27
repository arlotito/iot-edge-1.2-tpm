#!/bin/bash
sudo apt-get update

# install python 3.7
sudo apt-get install python3.7 -y

# make it the default alternative beside 3.6
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2 
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1

# installing python3.7 may have broken apt. Fix it:
cd /usr/lib/python3/dist-packages
sudo ln -s apt_pkg.cpython-36m-x86_64-linux-gnu.so apt_pkg.so