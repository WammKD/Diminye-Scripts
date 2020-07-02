#!/bin/dash

increment=25
max_file="/sys/class/backlight/*/max_brightness"
current_file="/sys/class/backlight/*/brightness"
max=$(cat $max_file)
current=$(cat $current_file)

notify_p=$(if
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

           	echo "true"
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

           	echo "true"
           else
           	echo "false"
           fi)



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


if
	[ "$(echo "$notify_p" | tail -n 1)" = "true" ]
then
	nIcon=$(case $percent in
	        	0)
	        		echo "notification-display-brightness-off"
	        		;;
	        	[1-9]|[1-2][0-9]|3[0-3])
	        		echo "notification-display-brightness-low"
	        		;;
	        	3[4-9]|[4-5][0-9]|6[0-7])
	        		echo "notification-display-brightness-medium"
	        		;;
	        	6[8-9]|[7-9][0-9])
	        		echo "notification-display-brightness-high"
	        		;;
	        	100)
	        		echo "notification-display-brightness-full"
	        		;;
	        	*)
	        		echo "ERROR"
	        		;;
	        esac)

	echo "notify-send $(seq -s '━' $(echo "scale = 2; $percent / 2.30" | bc | awk '{printf("%d\n",$1 - 0.5)}') | sed 's/[0-9]//g') -i $nIcon -h string:x-canonical-private-synchronous:brightness"
fi
