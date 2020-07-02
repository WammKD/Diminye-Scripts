#!/bin/bash
CM_DIR=~/.local/share/clipmenu CM_LAUNCHER=rofi clipmenu -font "Cantarell normal 13" -color-window argb:FFFFFFFF,#929291,#4A4F51 -color-normal argb:00E8E8E7,#000000,argb:00E8E8E7,#4A90D9,#FFFFFF

elem="$(xsel)"
lines="$(echo "$elem" | wc -l)"

# Escape it.
searchEscaped=$(sed -e 's/[^^]/[&]/g; s/\^/\\^/g; $!a\'$'\n''\\n' <<<"$(echo "$elem" | head -n 1)" | tr -d '\n')

CM_DIR=~/.local/share/clipmenu clipdel -d "$(if
                                             	[ $lines -gt 1 ]
                                             then
                                             	echo "^$searchEscaped ($lines lines)\$"
                                             else
                                             	echo "^$searchEscaped\$"
                                             fi)"
