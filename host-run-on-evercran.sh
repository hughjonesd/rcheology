#!/bin/bash

# TODO: run 4.3.2 when it's available
# TODO: make args capture whole args...
# TODO: R 0.60 and 0.60.1 and maybe 0.61 segfault, maybe try on different platform?

# useful commands:
# remove all stopped containers:
# docker container prune 
# create a bash shell:
# docker exec -it ctr-XXX /bin/bash

function setup_container {
  IMAGE=$1
  CONTAINER="ctr-$IMAGE"
  PLATFORM="linux/arm64"
  case $IMAGE in
    pre | 0.x | 1.x | 2.x ) PLATFORM="linux/i386"
  esac
  docker create --name $CONTAINER --platform $PLATFORM --entrypoint bash -i -t \
    "ghcr.io/r-hub/evercran/$IMAGE"
  docker cp guest-list-objects.R $CONTAINER:/root/
  docker cp guest-functions.R $CONTAINER:/root/
  docker cp guest-run-r-versions.sh $CONTAINER:/root/
  docker start $CONTAINER
}

function run_image {
  IMAGE=$1
  setup_container $IMAGE
  CONTAINER="ctr-$IMAGE"
  docker exec $CONTAINER chmod a+x /root/guest-run-r-versions.sh
  docker exec $CONTAINER /root/guest-run-r-versions.sh
  docker cp "$CONTAINER:/root/docker-data/." docker-data
  docker stop $CONTAINER
}

# run_image pre
# run_image 0.x
# run_image 1.x
# run_image 2.x
 
run_image 3.0.0
run_image 3.0.1
run_image 3.0.2
run_image 3.0.3
run_image 3.1.0
run_image 3.1.1
run_image 3.1.2
run_image 3.1.3
run_image 3.2.0
run_image 3.2.1
run_image 3.2.2
run_image 3.2.3
run_image 3.2.4
run_image 3.2.5
run_image 3.3.0
run_image 3.3.1
run_image 3.3.2
run_image 3.3.3
run_image 3.4.0
run_image 3.4.1
run_image 3.4.2
run_image 3.4.3
run_image 3.4.4
run_image 3.5.0
run_image 3.5.1
run_image 3.5.2
run_image 3.5.3
run_image 3.6.0
run_image 3.6.1
run_image 3.6.2
run_image 3.6.3
run_image 4.0.0
run_image 4.0.1
run_image 4.0.2
run_image 4.0.3
run_image 4.0.4
run_image 4.0.5
run_image 4.1.0
run_image 4.1.1
run_image 4.1.2
run_image 4.1.3
run_image 4.2.0
run_image 4.2.1
run_image 4.2.2
run_image 4.2.3
run_image 4.3.0
run_image 4.3.1
run_image 4.3.2
