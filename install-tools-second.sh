cd ~
while true; do sudo -v; sleep 60; done & SUDOPID=$!
flatpak install flathub com.usebottles.bottles fr.handbrake.ghb io.freetubeapp.FreeTube io.github.BrisklyDev.Brisk org.gimp.GIMP org.kde.krita org.musescore.MuseScore org.onlyoffice.desktopeditors org.telegram.desktop org.videolan.VLC -y
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
sudo apt install -f -y
sudo apt upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
flatpak update -y
kill "$SUDOPID"
exit
