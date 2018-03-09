# rcheology

A data package which lists every command in base R packages since R version 3.0.2.

## Installing

```
install.packages("remotes") # if you need to
remotes::install_github("hughjonesd/rcheology")
```

## Format

## Running it yourself

* Install docker
* Build the image from `Dockerfile` with `docker build -t rcheology .`
* Run the image with `docker run rcheology`.
* It will download and install multiple versions of R on the container.
* Check the container name with `docker container ls` (or `ls -a` after the process is finished).
* Source `gather-data.R` to get data out of the container and into a CSV file.

