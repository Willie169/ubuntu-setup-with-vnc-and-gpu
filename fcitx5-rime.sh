#!/usr/bin/env bash

sudo DEBIAN_FRONTEND=noninteractive apt install fcitx5 fcitx5-configtool fcitx5-frontend-all fcitx5-rime -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite"
