# build like `docker build -t rch_r3.5 .`
# run like `docker run  --name rch_r3.5_c rch_r3.5`

FROM trusty

RUN rm r-base-versions.txt
RUN apt-get remove -y -q -d r-base-core
RUN sed -i '$ d' /etc/apt/sources.list
RUN echo "deb https://cran.rstudio.com/bin/linux/ubuntu trusty-cran35/" >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get install -y -q -d r-base-core

RUN apt-cache madison r-base-core | grep rstudio | cut -d"|" -f 2 | perl -pe '$x = $_; $x =~ s/-.*//; s/^ //; $_ = "# $_" if $seen{$x}++;' > r-base-versions.txt

COPY install-versions.sh .
RUN chmod a+x install-versions.sh
COPY list-objects.R .
COPY write-table-backport.R .

CMD ["./install-versions.sh"]
