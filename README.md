
<!-- README.md is generated from README.Rmd. Please edit that file -->
rcheology
=========

[![Travis build status](https://travis-ci.org/hughjonesd/rcheology.svg?branch=master)](https://travis-ci.org/hughjonesd/rcheology) [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/rcheology?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/rcheology) [![CRAN status](https://www.r-pkg.org/badges/version/rcheology)](https://cran.r-project.org/package=rcheology)

A data package which lists every command in base R packages since R version 1.2.3.

The latest R version covered is 3.5.1.

Installing
----------

``` r
install.packages("remotes") # if you need to
remotes::install_github("hughjonesd/rcheology")
```

Where the data comes from
-------------------------

Versions 3.0.1 and up are installed from the [CRAN apt repositories for Ubuntu Trusty Tahr](https://cran.r-project.org/bin/linux/ubuntu/trusty/). Version 3.5.0 and up use a [special repository](https://cran.r-project.org/bin/linux/ubuntu/trusty-cran35/).

Versions 2.5.1 to 3.0.0 are built from source on [Ubuntu Lucid Lynx](https://hub.docker.com/r/yamamuteki/ubuntu-lucid-i386/).

Versions 1.2.3 to 2.4.1 are built from source on [Debian Sarge](https://hub.docker.com/r/debian/eol/).

Results are found from running `ls` on all installed packages from a minimal installation. Recommended packages are not included.

The `Rversions` data frame lists versions of R and release dates.

Do it yourself
--------------

-   Install docker
-   `./control build` builds the images. Or get them from <https://hub.docker.com/r/dash2/rcheology/>.
-   `./control run` runs the images to build/install R and extract data
-   `./control gather` gets CSV files from the containers
-   `./control write` puts CSV files into a data frame and stores it in the package

The data
--------

You can view the data online in a [Shiny app](https://hughjonesd.shinyapps.io/rcheology/).

``` r
library(rcheology)
data("rcheology")

head(rcheology)
#>   name    type class generic args package Rversion
#> 1    ! builtin  <NA>      NA <NA>    base    1.0.1
#> 2   != builtin  <NA>      NA <NA>    base    1.0.1
#> 3    $ special  <NA>      NA <NA>    base    1.0.1
#> 4  $<- special  <NA>      NA <NA>    base    1.0.1
#> 5   %% builtin  <NA>      NA <NA>    base    1.0.1
#> 6  %*% builtin  <NA>      NA <NA>    base    1.0.1
```

Base functions over time:

``` r
library(ggplot2)
suppressPackageStartupMessages(library(dplyr))
#> Warning: package 'dplyr' was built under R version 3.5.1

rvs <- rcheology$Rversion     %>% 
      unique()                %>% 
      as.package_version()    %>% 
      sort() %>% 
      as.character()

major_rvs <- grep(".0$", rvs, value = TRUE)
major_rv_dates <- Rversions$date[Rversions$Rversion %in% major_rvs]
major_rvs <- gsub("\\.0$", "", major_rvs)

rch_dates <- rcheology %>% left_join(Rversions, by = "Rversion")
ggplot(rch_dates, aes(date, group = package, fill = package), colour = NA) + 
      stat_count(geom = "area") + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) + 
      # ggthemes::scale_fill_gdocs() +
      scale_x_date(breaks  = major_rv_dates, labels = major_rvs) + 
      xlab("Version") + ylab("Function count") + 
      theme(legend.position = "top")
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

An alternative view:

``` r


ggplot(rch_dates, aes(date, fill = "orange")) + 
      stat_count(geom = "area") + 
      scale_x_date(breaks  = major_rv_dates, labels = major_rvs) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) + 
      xlab("Version") + ylab("Function count") + 
      facet_wrap(~package, scales = "free_y", ncol = 3) +
      theme(legend.position = "none") 
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />
