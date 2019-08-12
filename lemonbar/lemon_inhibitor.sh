#!/bin/dash

case "$1" in
    toggle)
	case $(xset -q | grep 'DPMS is' | awk '{ print $3 }')$(xset -q | grep 'timeout:' | awk '{ print $2 }') in
	    Disabled0)
		xset s on
		xset +dpms
		;;
	    *)
		xset s off
		xset -dpms
		;;
	esac
	;;
    off)
	xset s off
	xset -dpms
	;;
    on)
	xset s on
	xset +dpms
	;;
esac



icon=$(case $(xset -q | grep 'timeout:' | awk '{ print $2 }')$(xset -q | grep 'DPMS is'  | awk '{ print $3 }') in
	   0Disabled)
               echo $(/usr/bin/printf '\ue1d1')
	       ;;
	   *)
               echo $(/usr/bin/printf '\ue1d7')
	       ;;
       esac)

#printf "%s\n" "inhibitor%{U#f06292}%{+u}%{F#f06292}$icon %{F#FFFFFF}$(cut -d_ -f2 <<< $data)%{-u}"
echo "inhibitor%{A:if [ $(xset -q | grep 'DPMS is' | awk '{ print $3 }') = 'Enabled' ]; then xset -dpms; else xset +dpms; fi; ~/lemon_inhibitor.sh:}%{U#7e57c2}%{+u}%{F#7e57c2} $icon %{-u}%{A}" > "/tmp/panel_fifo"
