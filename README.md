
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rcheology

[![Travis build
status](https://travis-ci.org/hughjonesd/rcheology.svg?branch=master)](https://travis-ci.org/hughjonesd/rcheology)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/rcheology?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/rcheology)
[![CRAN
status](https://www.r-pkg.org/badges/version/rcheology)](https://cran.r-project.org/package=rcheology)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/rcheology)](https://cran.r-project.org/package=rcheology)

A data package which lists every command in base R packages since R
version 1.0.1.

The latest R version covered is 4.0.0.

You can view the data online in a [Shiny
app](https://hughjonesd.shinyapps.io/rcheology/).

## Installing

From CRAN:

``` r
install.packages('rcheology')
```

## Where the data comes from

Versions 4.0.0 and up are installed from the [CRAN apt repositories for
Ubuntu
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

Results are found from running `ls` on all installed packages from a
minimal installation. Recommended packages are not included.

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

head(rcheology)
#>   package name Rversion    type exported class generic args
#> 1    base    -    1.0.1 builtin     TRUE  <NA>      NA <NA>
#> 2    base    -    1.1.0 builtin     TRUE  <NA>      NA <NA>
#> 3    base    -    1.1.1 builtin     TRUE  <NA>      NA <NA>
#> 4    base    -    1.2.0 builtin     TRUE  <NA>      NA <NA>
#> 5    base    -    1.2.1 builtin     TRUE  <NA>      NA <NA>
#> 6    base    -    1.2.2 builtin     TRUE  <NA>      NA <NA>
```

Latest changes:

``` r

suppressPackageStartupMessages(library(dplyr))

r_penultimate <- sort(package_version(unique(rcheology::rcheology$Rversion)), 
      decreasing = TRUE)
r_penultimate <- r_penultimate[2]

r_latest_obj <- rcheology %>% filter(Rversion == r_latest)
r_penult_obj <- rcheology %>% filter(Rversion == r_penultimate)

r_introduced <- anti_join(r_latest_obj, r_penult_obj, by = c("package", "name"))

r_introduced
#>      package                  name Rversion        type exported       class
#> 1       base               .class2    4.0.0     builtin     TRUE    function
#> 2       base             .S3method    4.0.0     closure     TRUE    function
#> 3       base activeBindingFunction    4.0.0     closure     TRUE    function
#> 4       base      anyNA.data.frame    4.0.0     closure     TRUE    function
#> 5       base      as.list.difftime    4.0.0     closure     TRUE    function
#> 6       base              deparse1    4.0.0     closure     TRUE    function
#> 7       base globalCallingHandlers    4.0.0     closure     TRUE    function
#> 8       base               infoRDS    4.0.0     closure     TRUE    function
#> 9       base               list2DF    4.0.0     closure     TRUE    function
#> 10      base            marginSums    4.0.0     closure     TRUE    function
#> 11      base                  plot    4.0.0     closure     TRUE    function
#> 12      base           proportions    4.0.0     closure     TRUE    function
#> 13      base      sequence.default    4.0.0     closure     TRUE    function
#> 14      base          serverSocket    4.0.0     closure     TRUE    function
#> 15      base          socketAccept    4.0.0     closure     TRUE    function
#> 16      base         socketTimeout    4.0.0     closure     TRUE    function
#> 17      base      tryInvokeRestart    4.0.0     closure     TRUE    function
#> 18 grDevices       cairoSymbolFont    4.0.0     closure     TRUE    function
#> 19 grDevices        palette.colors    4.0.0     closure     TRUE    function
#> 20 grDevices          palette.pals    4.0.0     closure     TRUE    function
#> 21      grid             unit.psum    4.0.0     closure     TRUE    function
#> 22      grid              unitType    4.0.0     closure     TRUE    function
#> 23     stats                  Pair    4.0.0     closure     TRUE    function
#> 24    stats4       .__T__plot:base    4.0.0 environment     TRUE environment
#> 25     tools            R_user_dir    4.0.0     closure     TRUE    function
#>    generic
#> 1       NA
#> 2    FALSE
#> 3    FALSE
#> 4    FALSE
#> 5    FALSE
#> 6    FALSE
#> 7    FALSE
#> 8    FALSE
#> 9    FALSE
#> 10   FALSE
#> 11   FALSE
#> 12   FALSE
#> 13   FALSE
#> 14   FALSE
#> 15   FALSE
#> 16   FALSE
#> 17   FALSE
#> 18   FALSE
#> 19   FALSE
#> 20   FALSE
#> 21   FALSE
#> 22   FALSE
#> 23   FALSE
#> 24   FALSE
#> 25   FALSE
#>                                                                                                             args
#> 1                                                                                                            (x)
#> 2                                                                                       (generic, class, method)
#> 3                                                                                                     (sym, env)
#> 4                                                                                         (x, recursive = FALSE)
#> 5                                                                                                       (x, ...)
#> 6                                                               (expr, collapse = " ", width.cutoff = 500L, ...)
#> 7                                                                                                          (...)
#> 8                                                                                                         (file)
#> 9                                                                                      (x = list(), nrow = NULL)
#> 10                                                                                            (x, margin = NULL)
#> 11                                                                                                   (x, y, ...)
#> 12                                                                                            (x, margin = NULL)
#> 13                                                                               (nvec, from = 1L, by = 1L, ...)
#> 14                                                                                                        (port)
#> 15 (socket, blocking = FALSE, open = "a+", encoding = getOption("encoding"),     timeout = getOption("timeout"))
#> 16                                                                                        (socket, timeout = -1)
#> 17                                                                                                      (r, ...)
#> 18                                                                                       (family, usePUA = TRUE)
#> 19                                                     (n = NULL, palette = "Okabe-Ito", alpha, recycle = FALSE)
#> 20                                                                                                            ()
#> 21                                                                                                         (...)
#> 22                                                                                          (x, recurse = FALSE)
#> 23                                                                                                        (x, y)
#> 24                                                                                                          <NA>
#> 25                                                               (package, which = c("data", "config", "cache"))
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
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

An alternative view:

``` r


ggplot(rch_dates, aes(date, fill = "orange")) + 
      stat_count(geom = "area") + 
      scale_x_date(breaks  = major_rv_dates, labels = major_rvs) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) + 
      xlab("Version") + ylab("Function count") + 
      facet_wrap(~package, scales = "free_y", ncol = 2) +
      theme(legend.position = "none") 
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" height="1000px" />
