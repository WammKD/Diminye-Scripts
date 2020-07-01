#!/bin/dash

if
    [ "$1" = + ]
then
    amixer -M -c1 sset Master 3%+
elif
    [ "$1" = - ]
then
    amixer -M -c1 sset Master 3%-
elif
    [ "$1" = tog ]
then
    pulsemixer --toggle-mute
fi


sleep 0.03

data=$(amixer -M -c1 sget Master)
level=$(echo $data | awk -F"[][]" '/dB/ { print $2 }')
icon=$(if
       	[ $(echo $data | awk -F"[][]" '/dB/ { print $6 }') = on ]
       then
       	if
       		[ "$(amixer -M -c1 contents | grep -A2 Headphone\ .*Jack | grep values=o | cut -d = -f 2)" = "on" ]
       	then
       		case $(echo $level | awk -v len=${#level} '{ string=substr($0, 1, len - 1); print string; }') in
       			[0-9]|[1-4][0-9])
       				echo $(/usr/bin/printf '\ue0fc')
       				;;
       			*)
       				echo $(/usr/bin/printf '\ue0fd')
       				;;
       		esac
       	else
       		case $(echo $level | awk -v len=${#level} '{ string=substr($0, 1, len - 1); print string; }') in
       			[0-9]|[1-2][0-9]|3[0-3])
       				echo $(/usr/bin/printf '\ue04e')
       				;;
       			3[4-9]|[4-5][0-9]|6[0-7])
       				echo $(/usr/bin/printf '\ue050')
       				;;
       			6[8-9]|[7-9][0-9]|100)
       				echo $(/usr/bin/printf '\ue05d')
       				;;
       			*)
       				echo "ERROR"
       				;;
       		esac
       	fi
       else
       	echo $(/usr/bin/printf '\ue04f')
       fi)

if
    [ "${#level}" -le 3 ]
then
    level="$level%"
else
    level=$(echo $level | awk '{ string=substr($0, 1, 3); print string; }')
fi

echo "volume%{A:x-terminal-emulator -e pulsemixer &:}%{U#eb6637}%{+u}%{F#eb6637} $icon %{F#FFFFFF}$level %{-u}%{A}" > "/tmp/lemon/panel_fifo"
