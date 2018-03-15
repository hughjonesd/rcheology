#!/bin/bash


function download_compile {
  TARFILE="$1.tar.gz"
  echo "==============="
  echo "Compiling $TARFILE:"
  wget --quiet "https://cran.r-project.org/src/base/R-2/$TARFILE"
  if [[ $? > 0 ]]
  then
    echo "wget failed. Stopping."
    exit
  fi
  tar -zxf $TARFILE
  if [[ $? > 0 ]]
  then
    echo "untar failed. Stopping."
    exit
  fi
  
  cd $1
  # these speed up configuration but don't remove any functions from ls()
  # tcltk must be enabled though
  CFLAGS=-O0 FFLAGS=-O0 ./configure --with-recommended-packages=no --with-x=no --with-libpng=no --with-libjpeg=no
  make
  if [[ $? > 0 ]]
  then
    echo "make failed. Stopping."
    exit
  fi
  cd ..
}

function run_list_objects {
  cd $1
  echo "==============="
  echo "Running list-objects.R:"
  bin/R CMD BATCH --slave --no-timings ../list-objects.R ../docker-data/stdout-$1.out 2> ../docker-data/stderr-$1.out
  
  if [[ $? > 0 ]]
  then
    echo "R CMD BATCH failed. Stopping."
    exit
  fi
  cd ..
}

mapfile -t VERSIONS < R-2.x-source-versions.txt
NVERSIONS=${#VERSIONS[@]}
for (( i=$NVERSIONS-1; i>=0; i-- ))
do
  if [[ ${VERSIONS[$i]} =~ "#" ]] ; then continue; fi
  download_compile ${VERSIONS[$i]}
done 

for (( i=0; i<$NVERSIONS; i++ ))
do
  if [[ ${VERSIONS[$i]} =~ "#" ]] ; then continue; fi
  run_list_objects ${VERSIONS[$i]}
done 
