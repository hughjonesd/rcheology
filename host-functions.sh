# useful commands:
# remove all stopped containers:
# docker container prune 
# create a bash shell:
# docker exec -it ctr-XXX /bin/bash

function setup_ctr {
  IMAGE=$1
  CONTAINER="ctr-$IMAGE"
  PLATFORM="linux/arm64"
  case $IMAGE in
    pre | 0.* | 1.* | 2.* ) PLATFORM="linux/i386"
  esac
  
  docker stop $CONTAINER
  docker rm $CONTAINER
  rm -rf opt-R-volume
  
  mkdir -p opt-R-volume
  docker create --name $CONTAINER --platform $PLATFORM \
    --mount type=bind,source="$(pwd)"/opt-R-volume,destination=/root/opt-copy \
    --entrypoint bash -i -t "ghcr.io/r-hub/evercran/$IMAGE"
    
  docker cp guest-list-objects.R $CONTAINER:/root/
  docker cp guest-functions.R $CONTAINER:/root/
  docker cp guest-run-r-versions.sh $CONTAINER:/root/
  
  docker start $CONTAINER
  docker exec $CONTAINER chmod a+x /root/guest-run-r-versions.sh
  
  # we use this to avoid problems with i386 guest file systems on arm64
  docker exec $CONTAINER cp -R /opt/R/ /root/opt-copy
  docker exec $CONTAINER rm -rf /opt/R
  docker exec $CONTAINER ln -s /root/opt-copy/R /opt/R
  
  docker exec $CONTAINER apt-get update
  docker exec -e DEBIAN_FRONTEND=noninteractive $CONTAINER \
    apt-get install -y -q r-base-dev tclx8.4-dev tk8.4-dev \
    xvfb xbase-clients x-window-system-core
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
