cd ~
flatpak install flathub com.calibre_ebook.calibre com.discordapp.Discord com.getpostman.Postman com.obsproject.Studio com.spotify.Client fr.handbrake.ghb io.freetubeapp.FreeTube net.cozic.joplin_desktop org.chromium.Chromium org.gimp.GIMP org.gnome.Aisleriot org.kde.krita org.musescore.MuseScore org.onlyoffice.desktopeditors org.telegram.desktop org.videolan.VLC -y
sudo wget -q https://repo.steampowered.com/steam/archive/stable/steam.gpg | sudo tee /usr/share/keyrings/steam.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
EOF
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libgl1-mesa-dri:amd64 libgl1-mesa-dri:i386 libgl1-mesa-glx:amd64 libgl1-mesa-glx:i386 steam-launcher -y
sudo apt install -f -y
sudo apt full-upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
sudo reboot
