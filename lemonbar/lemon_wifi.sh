#!/bin/dash

data=$(nmcli -t -f active,ssid,bars dev wifi | grep yes)
bars=$(case $(echo $data | cut -d\: -f3) in
           "▂___")
               echo $(/usr/bin/printf '\ue25e')
               ;;
           "▂▄__")
               echo $(/usr/bin/printf '\ue25f')
               ;;
           "▂▄▆_")
               echo $(/usr/bin/printf '\ue260')
               ;;
           "▂▄▆█")
               echo $(/usr/bin/printf '\ue261')
               ;;
           *)
               echo $(/usr/bin/printf '\ue25d')
               ;;
       esac)

echo "wifi%{A:urxvt -sr -bl -e nmtui &:}%{U#00bcd4}%{+u}%{F#00bcd4} $bars %{F#FFFFFF}$(echo $data | cut -d\: -f2) %{-u}%{A}" > "/tmp/panel_fifo"
