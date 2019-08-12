#!/bin/dash

if
    [ "$1" = + ]
then
    amixer -c1 sset Master 3%+
elif
    [ "$1" = - ]
then
    amixer -c1 sset Master 3%-
elif
    [ "$1" = tog ]
then
    amixer -c1 sset Master toggle
fi


data=$(amixer -c1 sget Master)
level=$(echo $data | awk -F"[][]" '/dB/ { print $2 }')
icon=$(if
           [ $(echo $data | awk -F"[][]" '/dB/ { print $6 }') = on ]
       then
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

echo "volume%{A:urxvt -sr -bl -e alsamixer &:}%{U#eb6637}%{+u}%{F#eb6637} $icon %{F#FFFFFF}$level %{-u}%{A}" > "/tmp/panel_fifo"
