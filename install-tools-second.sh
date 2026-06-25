#!/bin/bash
source ~/.bashrc.d/50-functions.sh
flatpak --user override --filesystem=xdg-config/fontconfig:ro
flatpak install flathub com.github.vkohaupt.vokoscreenNG com.usebottles.bottles fr.handbrake.ghb io.ente.auth io.freetubeapp.FreeTube io.gitlab.news_flash.NewsFlash me.timschneeberger.jdsp4linux org.freecad.FreeCAD org.gimp.GIMP org.kde.kdenlive org.kde.tokodon org.localsend.localsend_app org.luanti.luanti org.musescore.MuseScore org.telegram.desktop org.videolan.VLC -y
flatpak update -y
gh_latest Elleo/pied com.mikeasoft.pied.flatpak
sudo flatpak install com.mikeasoft.pied.flatpak -y
rm com.mikeasoft.pied.flatpak*
sudo ufw allow 53317
sudo ufw reload
