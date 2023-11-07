#!/bin/bash

mkdir -p docker-data

/usr/X11R6/bin/Xvfb :0 -ac -screen 0 1960x2000x24 &

for RVERSION in /opt/R/*; do
  RBIN="$RVERSION/bin/R"
  echo "Starting $RBIN"
  RBASE=$(basename $RVERSION)
  RERR="docker-data/error-$RBASE.txt"
  RARGS="--no-restore --no-save -nosave"
  case $RBASE in
    0.49 | 0.50-a1 | 0.50-a4 ) RARGS=""
  esac
  $RBIN $RARGS < guest-list-objects.R 1>$RERR 
done 
wait
