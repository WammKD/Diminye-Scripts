#!/bin/dash

color_alert="#c03630"
color_norm="#FFFFFF"
color_charging="#87b158"
stuff=$(acpi -b | while read -r batt
                  do
                      BATTERY_STATE=$(echo "${batt}" | grep -wo "Full\|Charging\|Discharging")
                      BATTERY_POWER=$(echo "${batt}" | grep -o  '[0-9]\+%' | sed 's/%//g')

                      if
                          [ "${BATTERY_STATE}" = "Full" ] || [ "${BATTERY_POWER}" -eq 100 ]
                      then
                          result="%{U$color_charging}%{F$color_charging}$(/usr/bin/printf '\ue201')"
                          percent="$BATTERY_POWER"
                      else
                          if
                              [ "${BATTERY_POWER}" -le 10 ]
                          then
                              color="$color_alert"
                          else
                              color="$color_charging"
                          fi

                          if
                              [ "${BATTERY_STATE}" = "Discharging" ]
                          then
                              percent="$BATTERY_POWER%%"
                          else
                              percent="$BATTERY_POWER$(/usr/bin/printf '\ue09e')"
                          fi



                          if
                              [ "${BATTERY_POWER}" -le 33 ]
                          then
                              icon="$(/usr/bin/printf '\ue1fd')"
                          elif
                              [ "${BATTERY_POWER}" -le 67 ]
                          then
                              icon="$(/usr/bin/printf '\ue1fe')"
                          else
                              icon="$(/usr/bin/printf '\ue1ff')"
                          fi

                          result="%{U$color}%{F$color} $icon"
                      fi

                      echo "$result %{F#FFFFFF}$percent"
                  done)

echo "battery%{+u}$stuff %{-u}" > "/tmp/panel_fifo"
