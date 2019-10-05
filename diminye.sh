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
		             fontconfig         # fc-cache
		             wmctrl             # for use with deklanche
		             xdotool            # for use with deklanche
		             xsel               # for use with clipmenu

		             ### desktop utilities/general-uses
		             compton
		             xdg-user-dirs
		             xdg-utils
		             gtk-update-icon-cache
		             gtk3-nocsd
		             ttf-ancient-fonts
		             fonts-cantarell
		             gnome-themes-standard
		             papirus-icon-theme
		             # libreoffice-style-papirus
		             lxappearance
		             lxappearance-obconf

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
		             gnome-screenshot
		             xarchiver
		             gnome-calculator
		             xfce4-power-manager
		             thunar
		             thunar-archive-plugin
		             thunar-volman
		             catfish)
		# Uncommented elements are things I'm uncertain about
		sudo apt-get install --no-install-recommends ${packagelist[@]}

		echo 'source /etc/profile.d/undistract-me.sh' >> ~/.bashrc

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

		     cp    gtk/.gtkrc-2.0   ~/

		sudo cp -r gtk/openbox-3    /usr/share/themes/Adwaita
		### i3lock
		sudo cp i3lock/xflock4 /usr/local/bin
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
		### Xdefaults
		cp urxvt/.Xdefaults ~
		### XDG
		cp xdg/user-dirs.dirs ~/.config

		mkdir -p ~/Desktop
		mkdir -p ~/Downloads
		mkdir -p ~/Games
		mkdir -p ~/Templates
		mkdir -p ~/Public
		mkdir -p ~/Documents
		mkdir -p ~/Music
		mkdir -p ~/Pictures
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
