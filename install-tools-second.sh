#!/bin/bash
[ "${1:-}" = '--test' ] && TEST=1 || TEST=0
# shellcheck disable=2155
PREDF=$(df --output=used / | tail -n1)
. <(curl -fsSL https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/50-functions.sh)
flatpak --user override --filesystem=xdg-config/fontconfig:ro
flatpak install flathub com.github.vkohaupt.vokoscreenNG com.usebottles.bottles fr.handbrake.ghb io.ente.auth io.freetubeapp.FreeTube io.gitlab.news_flash.NewsFlash me.timschneeberger.jdsp4linux org.freecad.FreeCAD org.gimp.GIMP org.kde.kdenlive org.kde.tokodon org.localsend.localsend_app org.luanti.luanti org.musescore.MuseScore org.telegram.desktop org.videolan.VLC -y
flatpak update -y
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' Elleo/pied com.mikeasoft.pied.flatpak
if [ "$TEST" -eq 0 ]; then
sudo flatpak install com.mikeasoft.pied.flatpak -y
else
flatpak install com.mikeasoft.pied.flatpak -y
fi
rm com.mikeasoft.pied.flatpak*
if [ "$TEST" -eq 0 ]; then
sudo ufw allow 53317
sudo ufw reload
fi
# shellcheck disable=2155
POSTDF=$(df --output=used / | tail -n1)
echo "PREDF: $PREDF"
echo "POSTDF: $POSTDF"
