#!/bin/bash
# MinimalLinux Universal Installer
# Works on Debian ARM64 and Ubuntu Desktop

set -e

echo "Detecting OS..."
if [ -f /etc/debian_version ]; then
    OS="Debian"
elif [ -f /etc/lsb-release ]; then
    OS="Ubuntu"
else
    echo "Unsupported OS. Exiting."
    exit 1
fi
echo "OS detected: $OS"

echo "Updating system..."
sudo apt update && sudo apt full-upgrade -y

echo "Installing XFCE4 and LightDM if missing..."
sudo apt install xfce4 xfce4-goodies lightdm yad wmctrl thunar vlc gthumb \
firefox-esr thunderbird libreoffice-writer libreoffice-calc --no-install-recommends -y

echo "Removing unnecessary packages..."
sudo apt remove parole mousepad orage ristretto xfce4-notifyd gnome-sudoku games-* -y || true

echo "Configuring Calm Desktop Mode..."

# Remove XFCE panel
xfconf-query -c xfce4-panel -p /panels -r -R || true

# Disable Alt+Tab switching
xfconf-query -c xfwm4 -p /general/disable_alt_tab -s true || true

# Single workspace
xfconf-query -c xfwm4 -p /general/workspace_count -s 1

# Solid background (no wallpaper)
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-style -s 0
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/color-style -s 0
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/rgba1 -s "rgba(240,240,240,1)"

# Disable right-click menu
xfconf-query -c xfce4-desktop -p /desktop-icons/enable-context-menu -s false

# Large desktop icons
xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -s 128
xfconf-query -c xfce4-desktop -p /desktop-icons/locked -s true

echo "Creating desktop launchers..."
DESKTOP=~/Desktop
mkdir -p "$DESKTOP"

# Files
cat > "$DESKTOP/Files.desktop" <<EOL
[Desktop Entry]
Name=Files
Exec=thunar
Icon=folder
Terminal=false
Type=Application
EOL

# Internet
cat > "$DESKTOP/Internet.desktop" <<EOL
[Desktop Entry]
Name=Internet
Exec=firefox-esr
Icon=web-browser
Terminal=false
Type=Application
EOL

# Email
cat > "$DESKTOP/Email.desktop" <<EOL
[Desktop Entry]
Name=Email
Exec=thunderbird
Icon=mail-message-new
Terminal=false
Type=Application
EOL

# Documents
cat > "$DESKTOP/Documents.desktop" <<EOL
[Desktop Entry]
Name=Documents
Exec=libreoffice --writer
Icon=accessories-text-editor
Terminal=false
Type=Application
EOL

# Videos
cat > "$DESKTOP/Videos.desktop" <<EOL
[Desktop Entry]
Name=Videos
Exec=vlc
Icon=video-x-generic
Terminal=false
Type=Application
EOL

# Photos
cat > "$DESKTOP/Photos.desktop" <<EOL
[Desktop Entry]
Name=Photos
Exec=gthumb
Icon=folder-pictures
Terminal=false
Type=Application
EOL

# Shutdown
cat > "$DESKTOP/Shutdown.desktop" <<EOL
[Desktop Entry]
Name=Shutdown
Exec=xfce4-session-logout --halt
Icon=system-shutdown
Terminal=false
Type=Application
EOL

chmod +x "$DESKTOP"/*.desktop

echo "Creating floating Home button..."
mkdir -p ~/bin
cat > ~/bin/home_button.sh <<EOL
#!/bin/bash
yad --image=home --no-buttons --fixed --sticky --skip-taskbar \
--geometry=64x64+10+10 --onclick="wmctrl -k on; wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz"
EOL

chmod +x ~/bin/home_button.sh

mkdir -p ~/.config/autostart
cat > ~/.config/autostart/home_button.desktop <<EOL
[Desktop Entry]
Type=Application
Name=HomeButton
Exec=$HOME/bin/home_button.sh
EOL

echo "MinimalLinux setup complete!"
echo "Reboot to experience Calm Desktop mode with friendly launchers and floating Home button."
