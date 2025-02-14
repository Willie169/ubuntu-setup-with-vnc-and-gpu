sudo apt install gnome-session-flashback tigervnc-standalone-server tigervnc-viewer tigervnc-xorg-extension -y
vncpasswd
echo '#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="GNOME-Flashback:Unity"
export XDG_MENU_PREFIX="gnome-flashback-"
gnome-session --session=gnome-flashback-metacity --disable-acceleration-check
' >> ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup
# client: `ssh -L 5901:localhost:5901 user@ip`
## source: https://www.youtube.com/watch?v=0ICSWkuKlG4