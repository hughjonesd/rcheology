
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rcheology

[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/rcheology?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/rcheology)
![runiverse-package
badge](https://hughjonesd.r-universe.dev/badges/rcheology) [![CRAN
status](https://www.r-pkg.org/badges/version/rcheology)](https://cran.r-project.org/package=rcheology)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/rcheology)](https://cran.r-project.org/package=rcheology)

A data package which lists every command in base R packages since R
version 1.0.1.

The latest R version covered is 4.3.1.

You can view the data online in a [Shiny
app](https://hughjonesd.shinyapps.io/rcheology/).

## Installing

From
[r-universe](https://r-universe.dev):

``` r
install.packages('rcheology', repos = c('https://hughjonesd.r-universe.dev', 
                    'https://cloud.r-project.org'))
```

From CRAN:

``` r
install.packages('rcheology')
```

<!-- this is .Rmd so it can be easily included by README.Rmd -->

## Where the data comes from

Versions 4.2.1 and up are installed from the [CRAN apt repositories for
Ubuntu
Focal](https://cran.r-project.org/bin/linux/ubuntu/focal-cran40/).

Versions 4.0.0 to 4.2.0 are installed from the [CRAN apt repositories
for Ubuntu
Bionic](https://cran.r-project.org/bin/linux/ubuntu/bionic-cran40/).

Versions 3.0.1 to 3.6.3 are installed from the [CRAN apt repositories
for Ubuntu Trusty
Tahr](https://cran.r-project.org/bin/linux/ubuntu/trusty/). Version
3.5.0 and up use a [special
repository](https://cran.r-project.org/bin/linux/ubuntu/trusty-cran35/).

Versions 2.5.1 to 3.0.0 are built from source on [Ubuntu Lucid
Lynx](https://hub.docker.com/r/yamamuteki/ubuntu-lucid-i386/).

Versions 1.2.3 to 2.4.1 are mostly built from source on [Debian
Sarge](https://hub.docker.com/r/debian/eol/).

Versions 1.0.1 to 1.2.2 (and a couple of later versions) are built from
source on [Debian Woody](https://hub.docker.com/r/debian/eol/).

Results are found from running `ls(all.names = TRUE)` on all installed
packages from a minimal installation. For more details, see
`list-objects.R`.

Recommended packages are not included.

The `Rversions` data frame lists versions of R and release dates.

## Do it yourself

  - Install docker.
  - `./control build` builds the images. Or get them from
    <https://hub.docker.com/r/dash2/rcheology/>.
  - `./control run` runs the images to build/install R and extract data
  - `./control gather` gets CSV files from the containers
  - `./control write` puts CSV files into a data frame and stores it in
    the package

## The data

``` r
library(rcheology)
data("rcheology")

rcheology[rcheology$name == "kmeans" & rcheology$Rversion %in% c("1.0.1", "1.9.0", "2.1.0", "3.0.2", "3.2.0", "4.0.2"), ]
#>        package   name Rversion    type exported    class generic
#> 216706     mva kmeans    1.0.1 closure     TRUE     <NA>   FALSE
#> 237563   stats kmeans    1.9.0 closure     TRUE function   FALSE
#> 237567   stats kmeans    2.1.0 closure     TRUE function   FALSE
#> 237606   stats kmeans    3.0.2 closure     TRUE function   FALSE
#> 237611   stats kmeans    3.2.0 closure     TRUE function   FALSE
#>                                                                                                                              args
#> 216706                                                                                                (x, centers, iter.max = 10)
#> 237563                                                                                                (x, centers, iter.max = 10)
#> 237567                  (x, centers, iter.max = 10, nstart = 1, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"))
#> 237606   (x, centers, iter.max = 10, nstart = 1, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
#> 237611 (x, centers, iter.max = 10L, nstart = 1L, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
#>  [ reached 'max' / getOption("max.print") -- omitted 1 rows ]
```

Latest changes:

``` r

suppressPackageStartupMessages(library(dplyr))

r_penultimate <- sort(package_version(unique(rcheology::rcheology$Rversion)), 
      decreasing = TRUE)
r_penultimate <- r_penultimate[2]

r_latest_obj <- rcheology %>% dplyr::filter(Rversion == r_latest)
r_penult_obj <- rcheology %>% dplyr::filter(Rversion == r_penultimate)

r_introduced <- anti_join(r_latest_obj, r_penult_obj, by = c("package", "name"))

r_introduced
#> [1] package  name     Rversion type     exported class    generic  args    
#> <0 rows> (or 0-length row.names)
```

Base functions over time:

``` r
library(ggplot2)

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
#> Warning: Removed 3498 rows containing non-finite values (`stat_count()`).
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

An alternative view:

``` r


ggplot(rch_dates, aes(date, fill = "orange")) + 
      stat_count(geom = "area") + 
      scale_x_date(breaks  = major_rv_dates, labels = major_rvs) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) + 
      xlab("Version") + ylab("Function count") + 
      facet_wrap(~package, scales = "free_y", ncol = 2) +
      theme(legend.position = "none") 
#> Warning: Removed 3498 rows containing non-finite values (`stat_count()`).
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" height="1000px" />
