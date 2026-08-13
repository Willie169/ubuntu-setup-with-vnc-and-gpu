#!/usr/bin/env bash

sudo apt update
echo y | sudo ubuntu-drivers install || true
sudo apt install -f -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite"
echo y | sudo ubuntu-drivers install || true
sudo apt install -f -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite"
echo y | sudo ubuntu-drivers install || true
sudo apt install -f -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite"
echo y | sudo ubuntu-drivers autoinstall || true
sudo apt install -f -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite"
echo y | sudo ubuntu-drivers autoinstall || true
sudo apt install -f -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite"
echo y | sudo ubuntu-drivers autoinstall || true
sudo apt install -f -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite"
sudo reboot
