

docker create --name ctr-pre --platform linux/i386 --entrypoint bash -i -t \
  ghcr.io/r-hub/evercran/pre:latest
docker cp list-objects.R ctr-pre:/root/
docker start --attach -i ctr-pre
