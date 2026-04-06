flatpak install flathub com.usebottles.bottles fr.handbrake.ghb io.ente.auth io.freetubeapp.FreeTube io.github.BrisklyDev.Brisk io.gitlab.news_flash.NewsFlash org.gimp.GIMP org.gnome.SimpleScan org.kde.kdenlive org.kde.krita org.kde.tokodon org.localsend.localsend_app org.luanti.luanti org.musescore.MuseScore org.onlyoffice.desktopeditors org.videolan.VLC -y
flatpak update -y
gh_latest Elleo/pied com.mikeasoft.pied.flatpak
sudo flatpak install com.mikeasoft.pied.flatpak -y
rm com.mikeasoft.pied.flatpak*
sudo ufw allow 53317
sudo ufw reload
