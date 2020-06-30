#!/bin/bash

if
	[[ "${1}" == "--version" ]]
then
	exit 1
fi

inxi -Fxz

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
