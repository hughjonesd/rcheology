
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rcheology

[![Travis build
status](https://travis-ci.org/hughjonesd/rcheology.svg?branch=master)](https://travis-ci.org/hughjonesd/rcheology)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/rcheology?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/rcheology)
[![CRAN
status](https://www.r-pkg.org/badges/version/rcheology)](https://cran.r-project.org/package=rcheology)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/rcheology)](https://cran.rstudio.com/web/packages/rcheology/index.html)

A data package which lists every command in base R packages since R
version 1.0.1.

The latest R version covered is 3.6.0.

You can view the data online in a [Shiny
app](https://hughjonesd.shinyapps.io/rcheology/).

## Installing

From CRAN:

``` r
install.packages('rcheology')
```

From Github:

``` r
install.packages("remotes") # if you need to
remotes::install_github("hughjonesd/rcheology")
```

## Where the data comes from

Versions 3.0.1 and up are installed from the [CRAN apt repositories for
Ubuntu Trusty
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
#>      package                 name Rversion      type exported
#> 1       base         [[<-.POSIXlt    3.6.0   closure     TRUE
#> 2       base               asplit    3.6.0   closure     TRUE
#> 3       base        conflictRules    3.6.0   closure     TRUE
#> 4       base       errorCondition    3.6.0   closure     TRUE
#> 5       base         mem.maxNSize    3.6.0   closure     TRUE
#> 6       base         mem.maxVSize    3.6.0   closure     TRUE
#> 7       base             nullfile    3.6.0   closure     TRUE
#> 8       base packageNotFoundError    3.6.0   closure     TRUE
#> 9       base       str2expression    3.6.0   closure     TRUE
#> 10      base             str2lang    3.6.0   closure     TRUE
#> 11      base     warningCondition    3.6.0   closure     TRUE
#> 12 grDevices           hcl.colors    3.6.0   closure     TRUE
#> 13 grDevices             hcl.pals    3.6.0   closure     TRUE
#> 14      grid            delayGrob    3.6.0   closure     TRUE
#> 15      grid            deviceDim    3.6.0   closure     TRUE
#> 16      grid            deviceLoc    3.6.0   closure     TRUE
#> 17      grid          emptyCoords    3.6.0      list     TRUE
#> 18      grid           grobCoords    3.6.0   closure     TRUE
#> 19      grid           grobPoints    3.6.0   closure     TRUE
#> 20      grid        isEmptyCoords    3.6.0   closure     TRUE
#> 21   methods         .__C__double    3.6.0        S4     TRUE
#> 22     stats           DF2formula    3.6.0   closure     TRUE
#> 23     tools      update_PACKAGES    3.6.0   closure     TRUE
#> 24     tools         vignetteInfo    3.6.0   closure     TRUE
#> 25     utils            osVersion    3.6.0 character     TRUE
#>                  class generic
#> 1             function   FALSE
#> 2             function   FALSE
#> 3             function   FALSE
#> 4             function   FALSE
#> 5             function   FALSE
#> 6             function   FALSE
#> 7             function   FALSE
#> 8             function   FALSE
#> 9             function   FALSE
#> 10            function   FALSE
#> 11            function   FALSE
#> 12            function   FALSE
#> 13            function   FALSE
#> 14            function   FALSE
#> 15            function   FALSE
#> 16            function   FALSE
#> 17                list   FALSE
#> 18            function   FALSE
#> 19            function   FALSE
#> 20            function   FALSE
#> 21 classRepresentation   FALSE
#> 22            function   FALSE
#> 23            function   FALSE
#> 24            function   FALSE
#> 25           character   FALSE
#>                                                                                                                                                                                                               args
#> 1                                                                                                                                                                                                    (x, i, value)
#> 2                                                                                                                                                                                                      (x, MARGIN)
#> 3                                                                                                                                                                            (pkg, mask.ok = NULL, exclude = NULL)
#> 4                                                                                                                                                                        (message, ..., class = NULL, call = NULL)
#> 5                                                                                                                                                                                                      (nsize = 0)
#> 6                                                                                                                                                                                                      (vsize = 0)
#> 7                                                                                                                                                                                                               ()
#> 8                                                                                                                                                                                  (package, lib.loc, call = NULL)
#> 9                                                                                                                                                                                                           (text)
#> 10                                                                                                                                                                                                             (s)
#> 11                                                                                                                                                                       (message, ..., class = NULL, call = NULL)
#> 12                                                                                                                                           (n, palette = "viridis", alpha = NULL, rev = FALSE,     fixup = TRUE)
#> 13                                                                                                                                                                                                   (type = NULL)
#> 14                                                                                                                                                                 (expr, list, name = NULL, gp = NULL, vp = NULL)
#> 15                                                                                                                                                                                       (w, h, valueOnly = FALSE)
#> 16                                                                                                                                                                                       (x, y, valueOnly = FALSE)
#> 17                                                                                                                                                                                                            <NA>
#> 18                                                                                                                                                                                                (x, closed, ...)
#> 19                                                                                                                                                                                                (x, closed, ...)
#> 20                                                                                                                                                                                                        (coords)
#> 21                                                                                                                                                                                                            <NA>
#> 22                                                                                                                                                                                       (x, env = parent.frame())
#> 23 (dir = ".", fields = NULL, type = c("source", "mac.binary",     "win.binary"), verbose.level = as.integer(dryrun), latestOnly = TRUE,     addFiles = FALSE, rds_compress = "xz", strict = TRUE, dryrun = FALSE)
#> 24                                                                                                                                                                                                          (file)
#> 25                                                                                                                                                                                                            <NA>
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
