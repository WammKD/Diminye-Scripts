#!/bin/bash

wget -nv -O- https://wttr.in
# wmctrl -r :ACTIVE: -b add,maximized_horz && wmctrl -r :ACTIVE: -b add,maximized_vert

while
  [ true ]
do
  read -t 3 -n 1

  if
    [ $? = 0 ]
  then
    exit
  fi
done
