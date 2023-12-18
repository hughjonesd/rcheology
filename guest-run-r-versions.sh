#!/bin/bash

for RVERSION in /opt/R/*; do
  RBIN="$RVERSION/bin/R"
  
  RBASE=$(basename $RVERSION)
  RERR="errors/error-$RBASE.txt"
  
  RARGS="--no-restore --no-save -nosave"
  case $RBASE in
    0.49 | 0.50-a1 | 0.50-a4 ) RARGS="";;
    0.60* | 0.61* ) RARGS="-nosave";;
  esac
  
  echo "Starting $RBIN"
  RV=$RVERSION DISPLAY=host.docker.internal:1 $RBIN \
      $RARGS < guest-list-objects.R 1>$RERR 
done 

