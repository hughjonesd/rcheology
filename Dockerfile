FROM ubuntu:trusty

WORKDIR /rcheology
RUN mkdir shared-data
VOLUME /rcheology/shared-data

RUN apt-get -y update
RUN apt-get install -y apt-transport-https
RUN echo "deb https://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN apt-get -y update

COPY install-versions.sh .
RUN chmod a+x install-versions.sh
COPY list-objects.R .
COPY r-base-versions.txt .

CMD ["./install-versions.sh"]
