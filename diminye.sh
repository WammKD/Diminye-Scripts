#!/bin/bash
# This script owes a lot to CRubuntuNG for insight about how to approach this
# https://alkusin.net/crubuntung

# Avoid repeated requests for a password
grab_sudo() {
	sudo -v

	while
		[ true ]
	do
		sudo -n true

		sleep 45

		kill -0 "$$" || exit
	done 2>/dev/null &
}
notify_user() {
	echo -e "$1...\n\n"

	sleep 3s
}

# Grab the password for the first (and only) time
grab_sudo

clear
	notify_user "Setting swapiness to 10 and disabling install suggestions and recommendations"
		echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
		echo -e "APT::Install-Suggests \"0\";\nAPT::Install-Recommends \"0\";" | sudo tee /etc/apt/apt.conf.d/98disable-suggests-and-recommends

clear
	notify_user "Updating and upgrading apt"
		sudo apt -y update
		sudo apt -y upgrade

clear
	notify_user "Accepting Microsoft font license"  # In case it's ever made use of
		echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

clear
	notify_user "Installing packages"
		cd /tmp

		wget https://github.com/cdown/clipmenu/archive/5.6.0.tar.gz
		tar -zxvf 5.6.0.tar.gz
		cd clipmenu-5.6.0
		sudo mv clip* /usr/bin

		cd /tmp

		sudo add-apt-repository -y ppa:ubuntubudgie/backports
		sudo add-apt-repository -y ppa:papirus/papirus
		sudo apt-get            -y update

		packagelist=(# ubuntu-drivers-common
		             libavcodec-extra       # Allows things like watching Netflix

		             ### notifications
		             dunst
		             libnotify-bin
		             undistract-me

		             ### internets
		             network-manager

		             ### compression
		             zip unzip
		             rar unrar
		             p7zip-full

		             ### misc. utilities
		             x11-utils          # xev,xfontsel,xkill,xprop,etc.
		             x11-xserver-utils  # xrandr,xset
		             xfonts-utils       # mkfontdir
		             mesa-utils         # glxinfo for inxi; it's only 137kB
		             fontconfig         # fc-cache
		             wmctrl             # for use with deklanche
		             xdotool            # for use with deklanche
		             xsel               # for use with clipmenu

		             ### desktop utilities/general-uses
		             compton
		             inxi                       # For system info.; it's only 638kB
		             xdg-user-dirs
		             xdg-utils
		             policykit-1-gnome          # To be able to use policykit app.s (e.g. pkexec)
		             gtk-update-icon-cache
		             gtk3-nocsd
		             ttf-ancient-fonts
		             fonts-cantarell
		             gnome-themes-standard
		             adwaita-icon-theme-full    # For the cursors
		             papirus-icon-theme
		             # libreoffice-style-papirus
		             lxappearance
		             lxappearance-obconf
		             gnome-keyring
		             gnome-keyring-pkcs11       # For a certificate database
		             libpam-gnome-keyring       # Hopefully handle login unlocking
		             seahorse                   # GUI
		             libsecret-1-dev            # For Git functionality

		             ### desktop "panels"
		             acpi      # for detecting battery and audio jack changes
		             lemonbar
		             tint2

		             ### audio
		             pulseaudio
		             pulsemixer
		             alsa-utils

		             ### X11
		             openbox
		             xserver-xorg

		             ### applications
		             rxvt-unicode
		             skippy-xd
		             rofi
		             i3lock
		             # xautolock
		             # btscanner              # bluetooth
		             nitrogen
		             gdebi
		             viewnior
		             file-roller
		             gnome-calculator
		             gnome-screenshot
		             xfce4-power-manager
		             gvfs                   # For external drives
		             gvfs-backends          # For archive, ftp, http, mpt, smb…
		             gvfs-bin               # Basically, remote network access in Thunar
		             exfat-fuse
		             exfat-utils
		             ntfs-3g
		             tumbler                # To generate image thumbnails
		             thunar
		             thunar-archive-plugin
		             thunar-volman
		             catfish)
		# Commented out elements are things I'm uncertain about
		sudo apt-get install --no-install-recommends -y ${packagelist[@]}

		# Setup Git with Gnome Keyring
		cd /usr/share/doc/git/contrib/credential/libsecret
		sudo make
		git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
		cd /tmp

		echo 'source /etc/profile.d/undistract-me.sh' >> ~/.bashrc

		# Setup Gnome-Keyring for automatic unlock on login
		#sudo sed -i 's/auth       optional   pam_group.so/auth       optional   pam_group.so\nauth       optional   pam_gnome_keyring.so/' /etc/pam.d/login
		#sudo sed -i 's/session    optional   pam_keyinit.so force revoke/session    optional   pam_keyinit.so       force revoke\nsession    optional   pam_gnome_keyring.so auto_start/' /etc/pam.d/login
		#sudo sed -i 's/@/password      optional   pam_gnome_keyring.so\n\n@/' /etc/pam.d/passwd

		mkdir -p ~/.local/share/applications
		cp /usr/share/applications/rxvt-unicode.desktop ~/.local/share/applications
		sed -i 's/urxvt_48x48.xpm/\/usr\/share\/icons\/Papirus\/64x64\/apps\/xterm.svg/g' ~/.local/share/applications/rxvt-unicode.desktop

		cd /tmp

		wget https://github.com/stark/siji/archive/master.tar.gz
		tar -zxvf master.tar.gz
		rm master.tar.gz
		cd siji-master
		./install.sh

		cd /tmp

		wget https://github.com/cylgom/ly/releases/download/v0.3.0/ly_0.3.0.zip
		unzip ly_0.3.0.zip
		cd ly_0.3.0
		sudo ./install.sh
		sudo systemctl enable ly.service

		cd /tmp

		mkdir -p ~/.local/share/wallpapers
		mkdir -p ~/.config/nitrogen
		echo -e "[geometry]\nposx=429\nposy=124\nsizex=500\nsizey=500\n\n[nitrogen]\nview=icon\nrecurse=true\nsort=alpha\nicon_cap=false\ndirs=$HOME/.local/share/wallpapers;" > ~/.config/nitrogen/nitrogen.cfg
		wget https://github.com/elementary/wallpapers/archive/master.tar.gz
		tar -zxvf master.tar.gz
		rm master.tar.gz
		cp wallpapers-master/*.jpg ~/.local/share/wallpapers
		echo -e "[xin_-1]\nfile=$HOME/.local/share/wallpapers/Sunset by the Pier.jpg\nmode=0\nbgcolor=#E8E8E7" > ~/.config/nitrogen/bg-saved.cfg

		mkdir -p ~/.local/bin
		wget https://github.com/wammkd/diminye-scripts/archive/master.tar.gz
		tar -zxvf master.tar.gz
		cd Diminye-Scripts-master
		### ACPI
		sudo cp acpid/* /etc/acpi/events/
		### Aerosnap
		sudo cp aerosnap/deklanche /usr/local/bin
		### Dunst
		mkdir -p ~/.config/dunst
		cp dunst/dunstrc ~/.config/dunst/
		### GTK Settings
		mkdir -p ~/.config/gtk-3.0
		     cp    gtk/settings.ini ~/.config/gtk-3.0/
		echo -e "file://$HOME/Documents\nfile://$HOME/Downloads\nfile://$HOME/Games\nfile://$HOME/Music\nfile://$HOME/Pictures\nfile://$HOME/tmp\nfile://$HOME/Videos" > ~/.config/gtk-3.0/bookmarks

		     cp    gtk/.gtkrc-2.0   ~/

		sudo cp -r gtk/openbox-3    /usr/share/themes/Adwaita
		### i3lock
		sudo cp i3lock/xflock4 /usr/local/bin
		### Keyboard
		# sudo sed -i 's/XKBOPTIONS=""/XKBOPTIONS="compose:ralt"/g' /etc/default/keyboard
		### Lemonbar
		sudo cp lemonbar/lemon*.sh /usr/local/bin

		sudo cp lemonbar/98-lemon_wifi /etc/NetworkManager/dispatcher.d/

		echo 'ALL ALL=(root) NOPASSWD: /usr/local/bin/lemon_brightness.sh' | sudo EDITOR='tee -a' visudo
		### Network Manager
		sudo cp network_manager/tz-update /usr/local/bin

		echo 'ALL ALL=(root) NOPASSWD: /usr/local/bin/tz-update' | sudo EDITOR='tee -a' visudo

		echo '[ "$2" = "up" ] && sudo tz-update &' | sudo tee /etc/NetworkManager/dispatcher.d/99-tzupdate
		sudo chmod +x /etc/NetworkManager/dispatcher.d/99-tzupdate
		### Openbox
		mkdir -p ~/.config/openbox
		cp openbox/* ~/.config/openbox/
		### Skippy-XD
		mkdir -p ~/.config/skippy-xd
		cp skippy-xd/* ~/.config/skippy-xd/
		### Thunar
		mkdir -p ~/.config/Thunar
		cp thunar/* ~/.config/Thunar/
		### Tint2
		mkdir -p ~/.config/tint2
		cp tint2/tint2rc ~/.config/tint2/
		### Toggle Swap
		sudo cp ram_management/toggle_swap.sh /usr/local/bin
		### Xdefaults
		cp urxvt/.Xdefaults ~
		### XDG
		cp xdg/user-dirs.dirs ~/.config

		mkdir -p ~/Desktop
		mkdir -p ~/Downloads
		mkdir -p ~/Games
		cp -r Templates ~/
		mkdir -p ~/Public
		mkdir -p ~/Documents
		mkdir -p ~/Music
		mkdir -p ~/Pictures
		ln -s /tmp/ ~/tmp
		mkdir -p ~/Videos

		cd /tmp

clear
	notify_user "Disabling checking for internet connection on boot"
		sudo systemctl disable systemd-networkd-wait-online.service
		sudo systemctl mask    systemd-networkd-wait-online.service

clear
	notify_user "Disabling snapd systemd service"
		sudo systemctl stop    snapd.service snapd.seeded.service snapd.socket
		sudo systemctl disable snapd.service snapd.seeded.service snapd.socket

clear
	notify_user "Setting openbox as x-session-manager"
		sudo update-alternatives --set x-session-manager /usr/bin/openbox-session

clear
	read -p "Installation is finished. Please press ENTER to reboot."
		systemctl reboot
