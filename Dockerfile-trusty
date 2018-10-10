# build like `docker build -t trusty -f Dockerfile-trusty`
# run like `docker run  --name trusty trusty`

FROM ubuntu:trusty

WORKDIR /rcheology
RUN mkdir docker-data
VOLUME /rcheology/docker-data

RUN apt-get -y update
RUN apt-get install -y apt-transport-https
RUN echo "deb https://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN apt-get -y update
RUN apt-get install -y -q -d r-base-core

# the perl script comments out older versions
RUN apt-cache madison r-base-core | cut -d"|" -f 2 | perl -pe '$x = $_; $x =~ s/-.*//; s/^ //; $_ = "# $_" if $seen{$x}++;' > r-base-versions.txt

COPY install-versions.sh .
RUN chmod a+x install-versions.sh
COPY list-objects.R .
COPY write-table-backport.R .

CMD ["./install-versions.sh"]
