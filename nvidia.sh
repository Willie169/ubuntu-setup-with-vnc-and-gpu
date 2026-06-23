#!/bin/bash

cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT | grep -q 'nvidia_drm.modeset=1' || sudo sed -Ei "s/^GRUB_CMDLINE_LINUX_DEFAULT='(.*)'[ \t]*/GRUB_CMDLINE_LINUX_DEFAULT='\1 nvidia_drm.modeset=1'/" /etc/default/grub
sudo update-grub
sudo reboot
