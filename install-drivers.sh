#!/usr/bin/env bash

sudo apt update
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
sudo reboot
