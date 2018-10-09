# build like `docker build -t sarge -f Dockerfile-sarge .`
# run like `docker run --name sarge sarge`

FROM debian/eol:sarge

WORKDIR /rcheology
RUN mkdir docker-data
VOLUME /rcheology/docker-data

RUN apt-get -y update
# this seems to install much less than `apt-get build-dep r-base-core`
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q r-base-dev tclx8.4-dev tk8.4-dev xvfb xbase-clients x-window-system-core
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q wget 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q vim

COPY install-R-source-versions.sh .
RUN chmod a+x install-R-source-versions.sh
COPY list-objects.R .
COPY write-table-backport.R .
COPY R-versions-sarge.txt ./R-versions.txt

CMD ["./install-R-source-versions.sh"]

