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
final=$(echo $data | cut -d\: -f2)
trunced=$(case ${#final} in
              0)
                  echo $final
                  ;;
              [1-9]|1[0-6])
                  echo "$final "
                  ;;
              *)
                  echo $(echo $final | awk '{ string=substr($0, 1, 16); print string; }')$(/usr/bin/printf '\ue25d')" "
                  ;;
          esac)

echo "wifi%{A:urxvt -sr -bl -e nmtui &:}%{U#00bcd4}%{+u}%{F#00bcd4} $bars %{F#FFFFFF}$trunced%{-u}%{A}" > "$HOME/.panel_fifo"
