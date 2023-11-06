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
  # docker exec $CONTAINER apt-get update
  # docker exec $CONTAINER apt-get install -y xvfb xauth xfonts-base
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
