#!/bin/bash
sudo apt update
sudo apt install curl wget -y
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://www.kicad.org/download/linux -o kicad.html
# shellcheck disable=2155
export KICAD_VERSION="$(cat kicad.html | grep '<p>Current Version: <strong>' | sed 's/<p>Current Version: <strong>//; s/<\/strong><\/p>//')"
rm kicad.html
wget --tries=100 --retry-connrefused --waitretry=5 https://downloads.kicad.org/kicad/linux/explore/stable/download/kicad-"$KICAD_VERSION"-x86_64.AppImage.tar
tar -xf kicad-"$KICAD_VERSION"-x86_64.AppImage.tar
rm kicad-"$KICAD_VERSION"-x86_64.AppImage.tar
chmod +x kicad-"$KICAD_VERSION"-x86_64.AppImage
mkdir -p ~/.local/kicad
mv kicad-"$KICAD_VERSION"-x86_64.AppImage ~/.local/kicad
cat > ~/.local/bin/kicad <<EOF
#!/bin/bash
~/.local/kicad/kicad-$KICAD_VERSION-x86_64.AppImage
EOF
chmod +x ~/.local/bin/kicad
cd ~/.local/kicad || exit
wget --tries=100 --retry-connrefused --waitretry=5 https://gitlab.com/kicad/code/kicad/-/raw/master/resources/bitmaps_png/icons/icon_kicad.ico
cd ~ || exit
cat > ~/.local/share/applications/kicad.desktop <<EOF
[Desktop Entry]
Version=$KICAD_VERSION
Type=Application
Name=KiCad
Comment=KiCad - Schematic Capture & PCB Design Software
Exec=$HOME/.local/kicad/kicad-$KICAD_VERSION-x86_64.AppImage
Icon=$HOME/.local/kicad/icon_kicad.ico
Terminal=false
Categories=Development;
EOF
