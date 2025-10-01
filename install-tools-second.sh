cd ~
flatpak install flathub com.calibre_ebook.calibre com.discordapp.Discord com.getpostman.Postman com.obsproject.Studio com.spotify.Client fr.handbrake.ghb io.freetubeapp.FreeTube net.cozic.joplin_desktop org.chromium.Chromium org.gimp.GIMP org.gnome.Aisleriot org.kde.krita org.musescore.MuseScore org.onlyoffice.desktopeditors org.telegram.desktop org.videolan.VLC -y

sudo apt update
sudo apt install -f -y
sudo apt full-upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
sudo reboot
