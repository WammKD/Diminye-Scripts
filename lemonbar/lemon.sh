#!/bin/dash

###################
#  Initial Setup  #
###################

# Check if panl is already running
if
    [ $(pgrep -cx lemonbar) -gt 0 ]
then
    printf "%s\n" "The panel is already running." >&2
    exit 1
fi

# Stop processes on kill
trap 'trap - TERM; kill 0' INT TERM QUIT EXIT

# Remove old panel fifo; create new one
fifo_dir="/tmp/lemon"
fifo="$fifo_dir/panel_fifo"
[ -e "$fifo" ] && rm "$fifo"
mkdir -p "$fifo_dir"
mkfifo "$fifo"


##############
#  Elements  #
##############

clock() {  # sudo dpkg-reconfigure tzdata   to change timezone
    date_time=$(date '+%a: %B %d, %Y_%X, %Z')

    printf "%s\n" "clock%{A:gsimplecal &:}%{U#16a085}%{+u} %{F#FFFFFF}$(echo $date_time | cut -d _ -f 1) %{F#16a085}$(/usr/bin/printf '\ue26a')%{F#FFFFFF} $(echo $date_time | cut -d _ -f 2) %{-u}%{A}"
}

battery() {
    lemon_battery.sh
}

wifi() {
    lemon_wifi.sh
}

weather() {
    data=$(wget https://wttr.in/?format="%c_%t_%m_%p_%w" 2>/dev/null -O - | sed 's/+//g')
    icon=$(case $(echo $data | cut -d_ -f1) in
	       "⛅️")
                   echo $(case $(date '+%H') in
			      0[0-6]|19|2[0-9])
				  echo $(/usr/bin/printf '\ue232')
				  ;;
			      *)
				  echo $(/usr/bin/printf '\ue231')
				  ;;
			  esac)
		   ;;
	       "🌫")
                   echo $(/usr/bin/printf '\ue235')
		   ;;
	       "🌦")
		   echo $(/usr/bin/printf '\ue230')
		   ;;
               "☀️")
                   echo $(case $(date '+%H') in
			      0[0-6]|19|2[0-9])
				  echo $(/usr/bin/printf '\ue233')
				  ;;
			      *)
				  echo $(/usr/bin/printf '\ue234')
				  ;;
			  esac)
                   ;;
	       "☁️")
		   echo $(/usr/bin/printf '\ue22b')
		   ;;
	       "⛈")
		   echo $(/usr/bin/printf '\ue22d')
		   ;;
	       *)
		   echo "ERROR"
		   ;;
	   esac)
    text=$(result=$(echo $data | cut -d_ -f2)

	   if
	       [ ${#result} -gt 6 ]
	   then
	       echo ""
	   else
	       echo $result
	   fi)

    #printf "%s\n" "weather%{U#7e57c2}%{+u}%{F#7e57c2}$icon %{F#FFFFFF}$(cut -d_ -f2 <<< $data) %{F#7e57c2}| %{F#FFFFFF}$(cut -d_ -f4 <<< $data) %{F#7e57c2}| %{F#FFFFFF}$(cut -d_ -f5 <<< $data)%{-u}"
    #printf "%s\n" "weather%{U#7e57c2}%{+u}%{F#7e57c2}$icon %{F#FFFFFF}$(cut -d_ -f2 <<< $data)  %{F#7e57c2}$(cut -d_ -f3 <<< $data) %{F#FFFFFF}$(cut -d_ -f4 <<< $data) %{F#7e57c2}| %{F#FFFFFF}$(cut -d_ -f5 <<< $data)%{-u}"
    printf "%s\n" "weather%{A:urxvt -sr -bl -g 159x45 -e lemon_weather_launcher.sh &:}%{U#f06292}%{+u}%{F#f06292} $icon %{F#FFFFFF}$text %{-u}%{A}"
}

inhibitor() {
    lemon_inhibitor.sh
}

volume() {
    lemon_volume.sh
}

brightness() {
    lemon_brightness.sh
}

performance() {
    cpu=$(printf "%.2f\n" $(awk -v a="$(awk '/cpu /{print $2+$4,$2+$4+$5}' /proc/stat; sleep 0.3)" '/cpu /{split(a,b," "); print 100*($2+$4-b[1])/($2+$4+$5-b[2])}'  /proc/stat))%
    #cpu=$(top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }')
    ram=$(free | awk '/Mem/{printf("%.2f%"), $3/$2*100}')
    swap=$(free | awk '/Swap/{printf("%.2f%"), $3/$2*100}')

    printf "%s\n" "performance%{A:urxvt -sr -bl -e htop &:}%{U#E2B322}%{+u}%{F#E2B322} $(/usr/bin/printf '\ue224') %{F#FFFFFF}$cpu  %{F#E2B322} $(/usr/bin/printf '\ue020') %{F#FFFFFF}$ram  %{F#E2B322} $(/usr/bin/printf '\ue0ab') %{F#FFFFFF}$swap %{-u}%{A}"
}

partitions() {
    result="partitions%{U#5294e2}%{+u}"$(df -h | grep ^/dev/    \
                                               | grep -v /boot/ \
                                               | grep -v /snap/ \
                                               | while read -r partition
                                                 do
                                                     path=$(echo ${partition##*%} | awk '{ string=substr($0, 1); print string; }')
                                                     icon=$(if
                                                               [ "$path" = "/home" ]
                                                           then
                                                               echo $(/usr/bin/printf '\ue0b2')
                                                           elif
                                                               [ "$(echo $partition | awk '{ string=substr($0, 1, 8); print string; }')" != "/dev/sda" ]
                                                           then
                                                               echo $(/usr/bin/printf '\ue147')
                                                           else
                                                               echo $(/usr/bin/printf '\ue1e1')
                                                           fi)

                                                     echo -n "%{F#5294e2} %{A:thunar \"$path\" &:}$icon %{F#FFFFFF}$(echo $partition | cut -d \  -f 3) %{F#5294e2}/ %{F#FFFFFF}$(echo $partition | cut -d \  -f 2 )%{A} %{F#5294e2}"
                                                 done)"%{-u}"

    printf "%s\n" "$result"
}


# Run each element in a subshell and output to fifo
while :; do       clock; sleep  1s; done > "$fifo" &
while :; do     battery; sleep 20s; done > "$fifo" &
while :; do        wifi; sleep 20s; done > "$fifo" &
while :; do     weather; sleep 15m; done > "$fifo" &
while :; do      volume; sleep 30s; done > "$fifo" &
while :; do  brightness; sleep 30s; done > "$fifo" &
while :; do   inhibitor; sleep 30s; done > "$fifo" &
while :; do performance; sleep  1s; done > "$fifo" &
while :; do  partitions; sleep  1m; done > "$fifo" &


###################
#  Build the Bar  #
###################

while read -r line
do
    case $line in
        clock*)
            clock=$(echo $line | awk '{ string=substr($0, 6); print string; }')
            ;;
        battery*)
            battery=$(echo $line | awk '{ string=substr($0, 8); print string; }')
            ;;
        wifi*)
            wifi=$(echo $line | awk '{ string=substr($0, 5); print string; }')
            ;;
        volume*)
            volume=$(echo $line | awk '{ string=substr($0, 7); print string; }')
            ;;
        weather*)
            weather=$(echo $line | awk '{ string=substr($0, 8); print string; }')
            ;;
        inhibitor*)
            inhibitor=$(echo $line | awk '{ string=substr($0, 10); print string; }')
            ;;
        performance*)
            performance=$(echo $line | awk '{ string=substr($0, 12); print string; }')
            ;;
        brightness*)
            brightness=$(echo $line | awk '{ string=substr($0, 11); print string; }')
            ;;
        partitions*)
            partitions=$(echo $line | awk '{ string=substr($0, 11); print string; }')
            ;;
    esac

    printf "%s\n" "%{l}  ${partitions}   ${performance}%{c}${clock}%{r}${weather}   ${inhibitor}   ${volume}   ${brightness}   ${wifi}   ${battery}  "
done < "$fifo" | lemonbar -p                                                                     \
                          -g $(xprop -root _NET_WORKAREA | awk '{gsub(/,/,"");print $5}')x19+0+0 \
                          -B '#FF000000'                                                         \
                          -f 'fixed'                                                             \
                          -f '-wuncon-siji-medium-r-normal--10-100-75-75-c-80-iso10646-1'        \
               | bash; exit
