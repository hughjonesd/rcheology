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
# 
# If you get "no space left on device" errors, you can try
#   docker system prune

function setup_ctr {
  IMAGE=$1
  CONTAINER="ctr-$IMAGE"
  PLATFORM=""
  case $IMAGE in
    pre | 0.* | 1.* | 2.* ) PLATFORM="--platform=linux/i386" ;;
  esac
  
  docker image pull ghcr.io/r-hub/evercran/$IMAGE
  # A fresh Actions runner has no old container to remove.
  docker rm -f $CONTAINER 2>/dev/null || true
  
  docker create --name $CONTAINER $PLATFORM \
    -i -t "ghcr.io/r-hub/evercran/$IMAGE" 

  docker cp guest-list-objects.R $CONTAINER:/root/
  docker cp guest-html-help.R $CONTAINER:/root/
  docker cp guest-functions.R $CONTAINER:/root/
  docker cp guest-run-r-versions.sh $CONTAINER:/root/
  
  echo "Starting $CONTAINER ... be patient"
  docker start $CONTAINER
  docker exec $CONTAINER chmod a+x /root/guest-run-r-versions.sh
  
  docker exec $CONTAINER mkdir -p /root/docker-data /root/errors /root/help-site
}

function maybe_start_x {
  IMAGE=$1
  case $IMAGE in
    1.* | 2.* ) Xvfb :1 -listen tcp &
  esac
}

function maybe_stop_x {
  IMAGE=$1
  case $IMAGE in
    1.* | 2.* ) killall Xvfb ;;
  esac
}


function set_entrypoint {
  IMAGE=$1
  case $IMAGE in
    0.* | 1.* ) ENTRYPOINT="entrypoint.sh" ;;
    * ) ENTRYPOINT="" ;;
  esac
}


function run_image {
  IMAGE=$1
  HTML_HELP=$2
  setup_ctr $IMAGE
  CONTAINER="ctr-$IMAGE"

  maybe_start_x $IMAGE
  set_entrypoint $IMAGE
  docker exec $CONTAINER $ENTRYPOINT /root/guest-run-r-versions.sh $HTML_HELP
  docker cp "$CONTAINER:/root/docker-data/." docker-data
  if [ "$HTML_HELP" = "--html-help" ]; then
    mkdir -p help-site
    docker cp "$CONTAINER:/root/help-site/." help-site
  fi
  docker stop $CONTAINER
  maybe_stop_x $IMAGE
}


function login_ctr {
  IMAGE=$1
  CONTAINER="ctr-$IMAGE"
  docker start $CONTAINER
  
  set_entrypoint $IMAGE
  docker exec -it $CONTAINER $ENTRYPOINT /bin/bash
}
