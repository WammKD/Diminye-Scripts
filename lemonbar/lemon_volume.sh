#!/bin/dash

notify_p=$(if
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
           else
           	echo "false"
           fi)


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

if
	[ "$notify_p" != "false" ]
then
	nIcon=$(if
	        	[ $(echo $data | awk -F"[][]" '/dB/ { print $6 }') = on ]
	        then
	        	case $(echo $level | awk -v len=${#level} '{ string=substr($0, 1, len - 2); print string; }') in
	        		[0-9]|[1-2][0-9]|3[0-3])
	        			echo "notification-audio-volume-low"
	        			;;
	        		3[4-9]|[4-5][0-9]|6[0-7])
	        			echo "notification-audio-volume-medium"
	        			;;
	        		6[8-9]|[7-9][0-9]|100)
	        			echo "notification-audio-volume-high"
	        			;;
	        		*)
	        			echo "ERROR"
	        			;;
	        	esac
	        else
	        	echo "notification-audio-volume-muted"
	        fi)
	lev=$(if
	      	[ "$level" = "100" ]
	      then
	      	echo "100%%"
	      else
	      	echo "$level"
	      fi)
	bar=$(seq -s "━" $(echo "scale = 2; $(echo $lev | awk -v len=${#lev} '{ string=substr($0, 1, len - 2); print string; }') / 2.30" | bc | awk '{printf("%d\n",$1 - 0.5)}') | sed 's/[0-9]//g')

	notify-send "$(if [ "$bar" = "" ]; then echo " "; else echo $bar; fi)" -i "$nIcon" -h string:x-canonical-private-synchronous:volume
fi

echo "volume%{A:x-terminal-emulator -e pulsemixer &:}%{U#eb6637}%{+u}%{F#eb6637} $icon %{F#FFFFFF}$level %{-u}%{A}" > "/tmp/lemon/panel_fifo"
