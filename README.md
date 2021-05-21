
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

The latest R version covered is 4.1.0.

You can view the data online in a [Shiny
app](https://hughjonesd.shinyapps.io/rcheology/).

## Installing

From CRAN:

``` r
install.packages('rcheology')
```

<!-- this is .Rmd so it can be easily included by README.Rmd -->

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

-   Install docker.
-   `./control build` builds the images. Or get them from
    <https://hub.docker.com/r/dash2/rcheology/>.
-   `./control run` runs the images to build/install R and extract data
-   `./control gather` gets CSV files from the containers
-   `./control write` puts CSV files into a data frame and stores it in
    the package

## The data

``` r
library(rcheology)
data("rcheology")

rcheology[rcheology$name == "kmeans" & rcheology$Rversion %in% c("1.0.1", "1.9.0", "2.1.0", "3.0.2", "3.2.0", "4.0.2"), ]
#>        package   name Rversion    type exported    class generic
#> 195927     mva kmeans    1.0.1 closure     TRUE     <NA>   FALSE
#> 214723   stats kmeans    1.9.0 closure     TRUE function   FALSE
#> 214727   stats kmeans    2.1.0 closure     TRUE function   FALSE
#> 214766   stats kmeans    3.0.2 closure     TRUE function   FALSE
#> 214771   stats kmeans    3.2.0 closure     TRUE function   FALSE
#> 214796   stats kmeans    4.0.2 closure     TRUE function   FALSE
#>                                                                                                                              args
#> 195927                                                                                                (x, centers, iter.max = 10)
#> 214723                                                                                                (x, centers, iter.max = 10)
#> 214727                  (x, centers, iter.max = 10, nstart = 1, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"))
#> 214766   (x, centers, iter.max = 10, nstart = 1, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
#> 214771 (x, centers, iter.max = 10L, nstart = 1L, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
#> 214796 (x, centers, iter.max = 10L, nstart = 1L, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
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
#>      package                   name Rversion      type exported     class generic
#> 1       base               ...names    4.1.0   builtin     TRUE  function      NA
#> 2       base          .sys.timezone    4.1.0 character     TRUE character   FALSE
#> 3       base           [<-.difftime    4.1.0   closure     TRUE  function   FALSE
#> 4       base     all.equal.function    4.1.0   closure     TRUE  function   FALSE
#> 5       base               c.factor    4.1.0   closure     TRUE  function   FALSE
#> 6       base               gregexec    4.1.0   closure     TRUE  function   FALSE
#> 7       base                    isa    4.1.0   closure     TRUE  function   FALSE
#> 8       base              numToBits    4.1.0   closure     TRUE  function   FALSE
#> 9       base              numToInts    4.1.0   closure     TRUE  function   FALSE
#> 10      base           rep.difftime    4.1.0   closure     TRUE  function   FALSE
#> 11      base       xtfrm.data.frame    4.1.0   closure     TRUE  function   FALSE
#> 12 grDevices .linearGradientPattern    4.1.0   closure     TRUE  function   FALSE
#> 13 grDevices .radialGradientPattern    4.1.0   closure     TRUE  function   FALSE
#> 14 grDevices           .setClipPath    4.1.0   closure     TRUE  function   FALSE
#> 15 grDevices               .setMask    4.1.0   closure     TRUE  function   FALSE
#> 16 grDevices            .setPattern    4.1.0   closure     TRUE  function   FALSE
#> 17 grDevices         .tilingPattern    4.1.0   closure     TRUE  function   FALSE
#> 18      grid           editViewport    4.1.0   closure     TRUE  function   FALSE
#> 19      grid         linearGradient    4.1.0   closure     TRUE  function   FALSE
#> 20      grid                pattern    4.1.0   closure     TRUE  function   FALSE
#> 21      grid         radialGradient    4.1.0   closure     TRUE  function   FALSE
#> 22     tools        checkRdContents    4.1.0   closure     TRUE  function   FALSE
#> 23     utils              charClass    4.1.0   closure     TRUE  function   FALSE
#> 24     utils          RtangleFinish    4.1.0   closure     TRUE  function   FALSE
#> 25     utils         RtangleRuncode    4.1.0   closure     TRUE  function   FALSE
#>                                                                                                                                                                                                                                                                                                                           args
#> 1                                                                                                                                                                                                                                                                                                                           ()
#> 2                                                                                                                                                                                                                                                                                                                         <NA>
#> 3                                                                                                                                                                                                                                                                                                                (x, i, value)
#> 4                                                                                                                                                                                                                                                                             (target, current, check.environment = TRUE, ...)
#> 5                                                                                                                                                                                                                                                                                                      (..., recursive = TRUE)
#> 6                                                                                                                                                                                                                                      (pattern, text, ignore.case = FALSE, perl = FALSE, fixed = FALSE,     useBytes = FALSE)
#> 7                                                                                                                                                                                                                                                                                                                    (x, what)
#> 8                                                                                                                                                                                                                                                                                                                          (x)
#> 9                                                                                                                                                                                                                                                                                                                          (x)
#> 10                                                                                                                                                                                                                                                                                                                    (x, ...)
#> 11                                                                                                                                                                                                                                                                                                                         (x)
#> 12                                                                                                                                                                                        (colours = c("black", "white"), stops = seq(0, 1, length.out = length(colours)),     x1 = 0, y1 = 0, x2 = 1, y2 = 1, extend = "pad")
#> 13                                                                                                                                                                  (colours = c("black", "white"), stops = seq(0, 1, length.out = length(colours)),     cx1 = 0, cy1 = 0, r1 = 0, cx2 = 1, cy2 = 1, r2 = 0.5, extend = "pad")
#> 14                                                                                                                                                                                                                                                                                                               (path, index)
#> 15                                                                                                                                                                                                                                                                                                                 (mask, ref)
#> 16                                                                                                                                                                                                                                                                                                                   (pattern)
#> 17                                                                                                                                                                                                                                                                                          (fun, x, y, width, height, extend)
#> 18                                                                                                                                                                                                                                                                                              (vp = current.viewport(), ...)
#> 19                                                                 (colours = c("black", "white"), stops = seq(0, 1, length.out = length(colours)),     x1 = unit(0, "npc"), y1 = unit(0, "npc"), x2 = unit(1, "npc"),     y2 = unit(1, "npc"), default.units = "npc", extend = c("pad",         "repeat", "reflect", "none"))
#> 20                                                                                                            (grob, x = 0.5, y = 0.5, width = 1, height = 1, default.units = "npc",     just = "centre", hjust = NULL, vjust = NULL, extend = c("pad",         "repeat", "reflect", "none"), gp = gpar(fill = "transparent"))
#> 21 (colours = c("black", "white"), stops = seq(0, 1, length.out = length(colours)),     cx1 = unit(0.5, "npc"), cy1 = unit(0.5, "npc"), r1 = unit(0,         "npc"), cx2 = unit(0.5, "npc"), cy2 = unit(0.5, "npc"),     r2 = unit(0.5, "npc"), default.units = "npc", extend = c("pad",         "repeat", "reflect", "none"))
#> 22                                                                                                                                                                                                                                                                         (package, dir, lib.loc = NULL, chkInternal = FALSE)
#> 23                                                                                                                                                                                                                                                                                                                  (x, class)
#> 24                                                                                                                                                                                                                                                                                                     (object, error = FALSE)
#> 25                                                                                                                                                                                                                                                                                                    (object, chunk, options)
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
