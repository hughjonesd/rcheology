
<!-- README.md is generated from README.Rmd. Please edit that file -->
rcheology
=========

A data package which lists every command in base R packages since R version 3.0.2.

Installing
----------

``` r
install.packages("remotes") # if you need to
remotes::install_github("hughjonesd/rcheology")
```

Running it yourself
-------------------

-   Install docker
-   Build the image from `Dockerfile` with `docker build -t rcheology .`
-   Run the image with `docker run rcheology`.
-   It will download and install multiple versions of R on the container.
-   Check the container name with `docker container ls` (or `ls -a` after the process is finished).
-   Source `gather-data.R` to get data out of the container and into a CSV file.

Shiny app
---------

The data
--------

You can view the data online in a [Shiny app](https://hughjonesd.shinyapps.io/rcheology/).

``` r
library(rcheology)
data("rcheology")

head(rcheology)
#>        name    type    class               args package Rversion
#> 1         ! builtin function       function (x)    base    3.0.2
#> 2 !.hexmode closure function       function (a)    base    3.0.2
#> 3 !.octmode closure function       function (a)    base    3.0.2
#> 4        != builtin function  function (e1, e2)    base    3.0.2
#> 5         $ special function               NULL    base    3.0.2
#> 6 $.DLLInfo closure function function (x, name)    base    3.0.2
```

Base functions over time:

``` r

rvs <- unique(rcheology$Rversion)

palette(rainbow(7))
barplot(xtabs(~ Rversion + package, data = rcheology), 
        beside = TRUE, 
        las    = 2, 
        border = NA, 
        col    = heat.colors(length(rvs)),
        xlab   = "Package",
        ylab   = "Number of objects"
      )
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />
