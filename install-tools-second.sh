flatpak install flathub com.usebottles.bottles fr.handbrake.ghb io.ente.auth io.freetubeapp.FreeTube io.github.BrisklyDev.Brisk io.github.nozwock.Packet org.gimp.GIMP org.gnome.SimpleScan org.kde.alligator org.kde.kdenlive org.kde.krita org.kde.tokodon org.musescore.MuseScore org.onlyoffice.desktopeditors org.videolan.VLC -y
flatpak update -y
sudo ufw allow 9300
sudo ufw reload
