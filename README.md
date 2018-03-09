
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

The data
--------

``` r
library(rcheology)
data("rcheology")

head(rcheology)
#>        name    type    class generic package Rversion
#> 1         ! builtin function   FALSE    base    3.0.2
#> 2 !.hexmode closure function   FALSE    base    3.0.2
#> 3 !.octmode closure function   FALSE    base    3.0.2
#> 4        != builtin function    TRUE    base    3.0.2
#> 5         $ special function    TRUE    base    3.0.2
#> 6 $.DLLInfo closure function   FALSE    base    3.0.2
```

Packages over time

``` r
xtabs(~ Rversion + package, data = rcheology)
#>         package
#> Rversion base compiler datasets graphics grDevices grid methods parallel
#>    3.0.2 1166        9      103       87       106  188     216       32
#>    3.1.0 1177        9      103       87       106  198     216       32
#>    3.1.1 1177        9      103       87       106  198     216       32
#>    3.1.2 1180        9      103       87       106  198     216       32
#>    3.1.3 1182        9      103       87       106  198     216       32
#>    3.2.0 1203        9      104       87       107  198     216       32
#>    3.2.1 1203        9      104       87       107  198     216       32
#>    3.2.2 1203        9      104       87       107  198     216       32
#>    3.2.3 1203        9      104       87       107  198     216       32
#>    3.2.4 1203        9      104       87       107  198     216       32
#>    3.2.5 1203        9      104       87       107  198     216       32
#>    3.3.0 1212        9      104       87       107  198     217       32
#>    3.3.1 1213        9      104       87       107  198     217       32
#>    3.3.2 1214        9      104       87       107  198     217       32
#>    3.3.3 1214        9      104       87       107  198     217       32
#>    3.4.0 1217        9      104       87       107  198     218       32
#>    3.4.1 1217        9      104       87       107  198     218       32
#>    3.4.2 1217        9      104       87       107  198     218       32
#>    3.4.3 1217        9      104       87       107  198     218       32
#>         package
#> Rversion splines stats stats4 tcltk tools utils
#>    3.0.2      13   493     13   253    97   198
#>    3.1.0      13   446     13   253    99   201
#>    3.1.1      13   446     13   253    99   202
#>    3.1.2      13   446     13   253    99   202
#>    3.1.3      13   446     13   253    99   202
#>    3.2.0      13   446     13   254   103   205
#>    3.2.1      13   446     13   254   103   205
#>    3.2.2      13   446     13   259   103   205
#>    3.2.3      13   446     13   259   103   205
#>    3.2.4      13   446     13   259   103   205
#>    3.2.5      13   446     13   259   103   205
#>    3.3.0      13   447     13   259   108   206
#>    3.3.1      13   447     13   259   108   206
#>    3.3.2      13   447     13   259   108   206
#>    3.3.3      13   447     13   259   108   206
#>    3.4.0      13   447     13   259   115   211
#>    3.4.1      13   447     13   259   116   211
#>    3.4.2      13   447     13   259   116   211
#>    3.4.3      13   447     13   259   116   211
```

Running it yourself
-------------------

-   Install docker
-   Build the image from `Dockerfile` with `docker build -t rcheology .`
-   Run the image with `docker run rcheology`.
-   It will download and install multiple versions of R on the container.
-   Check the container name with `docker container ls` (or `ls -a` after the process is finished).
-   Source `gather-data.R` to get data out of the container and into a CSV file.
