
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

-   Install docker.
-   Source `gather-data.R` to:
    -   build the image
    -   run the container
    -   get data out of the container

The data
--------

You can view the data online in a [Shiny app](https://hughjonesd.shinyapps.io/rcheology/).

``` r
library(rcheology)
data("rcheology")

head(rcheology)
#>        name    type    class generic               args package Rversion
#> 1         ! builtin function   FALSE       function (x)    base    3.0.2
#> 2 !.hexmode closure function   FALSE       function (a)    base    3.0.2
#> 3 !.octmode closure function   FALSE       function (a)    base    3.0.2
#> 4        != builtin function    TRUE  function (e1, e2)    base    3.0.2
#> 5         $ special function    TRUE               <NA>    base    3.0.2
#> 6 $.DLLInfo closure function   FALSE function (x, name)    base    3.0.2
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
        ylab   = "Number of objects"
      )
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />
