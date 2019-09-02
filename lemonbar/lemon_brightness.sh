#!/bin/dash

increment=25
max_file="/sys/class/backlight/*/max_brightness"
current_file="/sys/class/backlight/*/brightness"
max=$(cat $max_file)
current=$(cat $current_file)

if
    [ "$1" = + ]
then
    result=$((current + $increment))

    if
	[ $result -gt $max ]
    then
	echo $max    | tee $current_file
    else
	echo $result | tee $current_file
    fi
elif
    [ "$1" = - ]
then
    result=$((current - $increment))

    if
	[ $result -lt 0 ]
    then
	echo 0       | tee $current_file
    else
	echo $result | tee $current_file
    fi
fi



new_current=$(cat $current_file)
icon=$(case $new_current in
	   [0-9]|[1-7][0-9]|8[0-5])
	       echo $(/usr/bin/printf '\ue1bc')
	       ;;
	   8[6-9]|9[0-9]|1[0-6][0-9]|170)
	       echo $(/usr/bin/printf '\ue1c3')
		   ;;
	   1[7-9][0-9]|2[0-4][0-9]|25[0-5])
	       echo $(/usr/bin/printf '\ue1c2')
	       ;;
	   *)
	       echo "ERROR"
	       ;;
       esac)
percent=$(echo "scale = 2; (($new_current / $max) * 100)" | bc)

echo "brightness%{U#ca71df}%{+u}%{F#ca71df} $icon %{F#FFFFFF}$(if [ ${#percent} -eq 6 ]; then echo 100; else echo $(echo $percent | cut -d . -f 1)%; fi) %{-u}" > "$HOME/.panel_fifo"
