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



percent=$(echo "scale = 2; (($(cat $current_file) / $max) * 100)" | bc | cut -d . -f 1)
icon=$(case $percent in
       	[0-9]|[1-2][0-9]|3[0-3])
       		echo $(/usr/bin/printf '\ue1bc')
       		;;
       	3[4-9]|[4-5][0-9]|6[0-7])
       		echo $(/usr/bin/printf '\ue1c3')
       		;;
       	6[8-9]|[7-9][0-9]|100)
       		echo $(/usr/bin/printf '\ue1c2')
       		;;
       	*)
       		echo "ERROR"
       		;;
       esac)


echo "brightness%{U#ca71df}%{+u}%{F#ca71df} $icon %{F#FFFFFF}$(if [ ${#percent} -eq 3 ]; then echo 100; else echo $percent%; fi) %{-u}" > "/tmp/lemon/panel_fifo"
