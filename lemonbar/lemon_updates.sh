#!/bin/dash

if
	[ "$1" = update ]
then
	x-terminal-emulator -e dash -c "sleep 0.1 && wmctrl -r :ACTIVE: -b add,maximized_horz,maximized_vert && sudo apt-get update && sudo apt-get upgrade && lemon_updates.sh" &
else
	if
		[ "$1" = dist ]
	then
		x-terminal-emulator -e dash -c "sleep 0.1 && wmctrl -r :ACTIVE: -b add,maximized_horz,maximized_vert && sudo apt-get update && sudo apt-get dist-upgrade && lemon_updates.sh" &
	else
		updates_and_security=$(/usr/lib/update-notifier/apt-check --human-readable | cut -d \  -f 1)

		echo "noti"$(number_of_updates=$(echo $updates_and_security | cut -d \  -f 1)

		             if
		             	[ $number_of_updates -ne 0 ]
		             then
		             	second=$(if
		             	         	[ -f /var/run/reboot-required ]
		             	         then
		             	         	echo $(/usr/bin/printf '\ue0b3')
		             	         else
		             	         	echo ""
		             	         fi)

		             	echo -n "%{A:x-terminal-emulator -e dash -c \"sleep 0.1 && wmctrl -r \:ACTIVE\: -b add,maximized_horz,maximized_vert && sudo apt-get update && sudo apt-get upgrade && lemon_updates.sh\" &:}%{U#5c6bc0}%{+u} %{F#5c6bc0}$(/usr/bin/printf '\ue0b3')$second %{F#FFFFFF}$number_of_updates %{-u}%{A}"
		             else
		             	echo -n ""
		             fi) > "/tmp/lemon/panel_fifo"
	fi
fi
