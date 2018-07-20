# build like `docker build -t woody -f Dockerfile-woody .`
# run like `docker run --name woody woody`

FROM debian/eol:woody

WORKDIR /rcheology
RUN mkdir docker-data
VOLUME /rcheology/docker-data

RUN apt-get -y update
# this seems to install much less than `apt-get build-dep r-base-core`
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q r-base-dev tclx8.3-dev tk8.3-dev xvfb xbase-clients x-window-system-core
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q wget 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q vim
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q man

COPY install-R-source-earlybash.sh .
RUN chmod a+x install-R-source-earlybash.sh
COPY list-objects.R .
COPY write-table-backport.R .
COPY R-versions-woody.txt ./R-versions.txt

CMD ["./install-R-source-earlybash.sh"]
