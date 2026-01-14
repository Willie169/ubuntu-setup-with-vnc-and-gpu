cd ~
while true; do sudo -v; sleep 60; done & SUDOPID=$!
trap 'kill "$SUDOPID"' EXIT
flatpak install flathub com.discordapp.Discord com.getpostman.Postman com.obsproject.Studio com.spotify.Client fr.handbrake.ghb io.freetubeapp.FreeTube io.github.BrisklyDev.Brisk net.cozic.joplin_desktop org.chromium.Chromium org.gimp.GIMP org.gnome.Aisleriot org.kde.krita org.musescore.MuseScore org.onlyoffice.desktopeditors org.telegram.desktop org.videolan.VLC -y
rm ~/.config/mimeapps.list || true
cat > ~/.config/mimeapps.list <<'EOF'
[Added Associations]
x-scheme-handler/http=firefox-esr.desktop;
x-scheme-handler/https=firefox-esr.desktop;

[Default Applications]
x-scheme-handler/http=firefox-esr.desktop;
x-scheme-handler/https=firefox-esr.desktop;
EOF
sudo apt update
sudo apt remove firefox --purge -y
sudo apt install -f -y
sudo apt full-upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
flatpak update -y
exit
