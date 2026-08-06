#!/usr/bin/env bash

cd ~ || exit
# shellcheck disable=2155
export UBUNTU_VERSION_ID=$(
	if grep -q '^NAME="Linux Mint"' /etc/os-release; then
		inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
	else
		. /etc/os-release
		echo "$VERSION_ID"
	fi
)
link="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${UBUNTU_VERSION_ID/./}/x86_64/cuda-keyring_1.1-1_all.deb"
wget --tries=100 --retry-connrefused --waitretry=5 "$link"
sudo apt install ./cuda-keyring_1.1-1_all.deb
rm cuda-keyring_1.1-1_all.deb*
sudo apt update
sudo apt install cuda-toolkit -y
