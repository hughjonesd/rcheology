#!/bin/bash

# useful commands:
# remove all stopped containers:
#   docker container prune 
# create a bash shell:
#   docker exec -it ctr-XXX /bin/bash
# list images:
#   docker image ls
# update an image
#   docker image pull ghcr.io/whatever

function setup_ctr {
  IMAGE=$1
  CONTAINER="ctr-$IMAGE"
  PLATFORM=""
  case $IMAGE in
    pre | 0.* | 1.* | 2.* ) PLATFORM="--platform=linux/i386"
  esac
  
  docker image pull ghcr.io/r-hub/evercran/$IMAGE
  docker stop $CONTAINER
  docker rm $CONTAINER
  
  docker create --name $CONTAINER $PLATFORM \
    -i -t "ghcr.io/r-hub/evercran/$IMAGE" 

  docker cp guest-list-objects.R $CONTAINER:/root/
  docker cp guest-functions.R $CONTAINER:/root/
  docker cp guest-run-r-versions.sh $CONTAINER:/root/
  
  echo "Starting $CONTAINER ... be patient"
  docker start $CONTAINER
  docker exec $CONTAINER chmod a+x /root/guest-run-r-versions.sh
  
  docker exec $CONTAINER mkdir /root/docker-data
  docker exec $CONTAINER mkdir /root/errors
}


function run_image {
  IMAGE=$1
  setup_ctr $IMAGE
  CONTAINER="ctr-$IMAGE"

  docker exec $CONTAINER /root/guest-run-r-versions.sh
  docker cp "$CONTAINER:/root/docker-data/." docker-data
  docker stop $CONTAINER
}


function login_ctr {
  IMAGE=$1
  CONTAINER="ctr-$IMAGE"
  docker start $CONTAINER
  docker exec -it $CONTAINER /bin/bash
}
