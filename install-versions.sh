#!/bin/bash

# launch docker with 
# "docker run XXX"
# where XXX is the image

function install_remove {
  APT_PACKAGE="r-base-core=$1"
  echo "==============="
  echo "Installing $APT_PACKAGE:"
  apt-get install -y -qq $APT_PACKAGE

  echo "==============="
  echo "Running list-objects.R:"
  Rscript list-objects.R 2> docker-data/stderr-$1.out
  
  echo "==============="
  echo "Removing r-base-core:"
  apt-get remove -y -qq r-base-core
  if [[ $? > 0 ]]
  then
    echo "apt-get remove failed. Stopping."
    exit
  fi
  # apt-get -y -qq autoremove
}

mapfile -t VERSIONS < r-base-versions.txt
NVERSIONS=${#VERSIONS[@]}
for (( i=0; i<$NVERSIONS; i++ ))
do
  if [[ ${VERSIONS[$i]} =~ "#" ]] ; then continue; fi
  install_remove ${VERSIONS[$i]}
done 

