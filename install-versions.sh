#!/bin/bash

# launch docker with 
# "docker run XXX"
# where XXX is the image

function install_remove {
  APT_PACKAGE="r-base-core=$1"
  echo "==============="
  echo "Installing $APT_PACKAGE:"
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -qq $APT_PACKAGE
  if [[ $? > 0 ]]
  then
    echo "apt-get install failed. Stopping."
    exit
  fi
  
  echo "==============="
  echo "Running list-objects.R:"
  Rscript list-objects.R 2> docker-data/stderr-$1.out
  
  echo "==============="
  echo "Removing r-base-core:"
  DEBIAN_FRONTEND=noninteractive apt-get remove -y -qq r-base-core
  if [[ $? > 0 ]]
  then
    echo "apt-get remove failed. Stopping."
    exit
  fi
  # apt-get -y -qq autoremove
}

HAS_MYV=0

if [[ -n $MYVERSIONS ]] ; then
  OIFS=$IFS
  IFS=','
  read -r -a MYV_ARRAY <<< "$MYVERSIONS"
  IFS=$OIFS
  HAS_MYV=1
fi


mapfile -t VERSIONS < r-base-versions.txt
NVERSIONS=${#VERSIONS[@]}
for (( i=0; i<$NVERSIONS; i++ ))
do
  if [[ ${VERSIONS[$i]} =~ "#" ]] ; then continue; fi
  if [[ $HAS_MYV == 1 ]]; then
    for MYV in "${MYV_ARRAY[@]}" 
    do
      if [[ ${VERSIONS[$i]} =~ "$MYV" ]] ; then 
        install_remove ${VERSIONS[$i]}
      fi
    done
  else
    install_remove ${VERSIONS[$i]}
  fi
done 

