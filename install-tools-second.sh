cd ~
flatpak install flathub com.discordapp.Discord com.getpostman.Postman com.obsproject.Studio com.spotify.Client fr.handbrake.ghb io.freetubeapp.FreeTube net.cozic.joplin_desktop org.chromium.Chromium org.gimp.GIMP org.gnome.Aisleriot org.kde.krita org.musescore.MuseScore org.onlyoffice.desktopeditors org.telegram.desktop org.videolan.VLC -y
sed -i '/^\[Default Applications\]/,${s/^x-scheme-handler\/http=.*/x-scheme-handler\/http=firefox-esr.desktop;/}' ~/.config/mimeapps.list
sed -i '/^\[Default Applications\]/,${s/^x-scheme-handler\/https=.*/x-scheme-handler\/https=firefox-esr.desktop;/}' ~/.config/mimeapps.list
exit
