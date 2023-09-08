#!/bin/sh

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

pkill mpd
mpd
mpc load all
mpc random
mpc repeat
mpc play
mpc pause
pkill recordmydesktop