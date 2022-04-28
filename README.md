
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rcheology

[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/rcheology?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/rcheology)
[![CRAN
status](https://www.r-pkg.org/badges/version/rcheology)](https://cran.r-project.org/package=rcheology)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/rcheology)](https://cran.r-project.org/package=rcheology)

A data package which lists every command in base R packages since R
version 1.0.1.

The latest R version covered is 4.2.0.

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
#> 205066     mva kmeans    1.0.1 closure     TRUE     <NA>   FALSE
#> 224778   stats kmeans    1.9.0 closure     TRUE function   FALSE
#> 224782   stats kmeans    2.1.0 closure     TRUE function   FALSE
#> 224821   stats kmeans    3.0.2 closure     TRUE function   FALSE
#> 224826   stats kmeans    3.2.0 closure     TRUE function   FALSE
#> 224851   stats kmeans    4.0.2 closure     TRUE function   FALSE
#>                                                                                                                              args
#> 205066                                                                                                (x, centers, iter.max = 10)
#> 224778                                                                                                (x, centers, iter.max = 10)
#> 224782                  (x, centers, iter.max = 10, nstart = 1, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"))
#> 224821   (x, centers, iter.max = 10, nstart = 1, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
#> 224826 (x, centers, iter.max = 10L, nstart = 1L, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
#> 224851 (x, centers, iter.max = 10L, nstart = 1L, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
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
#>      package                 name Rversion      type exported     class generic
#> 1       base       .LC.categories    4.2.0 character     TRUE character   FALSE
#> 2       base              .pretty    4.2.0   closure     TRUE  function   FALSE
#> 3       base as.vector.data.frame    4.2.0   closure     TRUE  function   FALSE
#> 4       base    as.vector.POSIXlt    4.2.0   closure     TRUE  function   FALSE
#> 5       base         last.warning    4.2.0      list     TRUE      list   FALSE
#> 6       base                mtfrm    4.2.0   closure     TRUE  function   FALSE
#> 7       base        mtfrm.default    4.2.0   closure     TRUE  function   FALSE
#> 8       base      Sys.setLanguage    4.2.0   closure     TRUE  function   FALSE
#> 9  grDevices            .clipPath    4.2.0   closure     TRUE  function   FALSE
#> 10 grDevices         .defineGroup    4.2.0   closure     TRUE  function   FALSE
#> 11 grDevices               .devUp    4.2.0   closure     TRUE  function   FALSE
#> 12 grDevices                .mask    4.2.0   closure     TRUE  function   FALSE
#> 13 grDevices             .opIndex    4.2.0   closure     TRUE  function   FALSE
#> 14 grDevices           .ruleIndex    4.2.0   closure     TRUE  function   FALSE
#> 15 grDevices            .useGroup    4.2.0   closure     TRUE  function   FALSE
#> 16      grid              as.mask    4.2.0   closure     TRUE  function   FALSE
#> 17      grid              as.path    4.2.0   closure     TRUE  function   FALSE
#> 18      grid           defineGrob    4.2.0   closure     TRUE  function   FALSE
#> 19      grid           defnRotate    4.2.0   closure     TRUE  function   FALSE
#> 20      grid            defnScale    4.2.0   closure     TRUE  function   FALSE
#> 21      grid        defnTranslate    4.2.0   closure     TRUE  function   FALSE
#> 22      grid      emptyGrobCoords    4.2.0   closure     TRUE  function   FALSE
#> 23      grid     emptyGTreeCoords    4.2.0   closure     TRUE  function   FALSE
#> 24      grid             fillGrob    4.2.0   closure     TRUE  function   FALSE
#> 25      grid       fillStrokeGrob    4.2.0   closure     TRUE  function   FALSE
#> 26      grid          grid.define    4.2.0   closure     TRUE  function   FALSE
#> 27      grid            grid.fill    4.2.0   closure     TRUE  function   FALSE
#> 28      grid      grid.fillStroke    4.2.0   closure     TRUE  function   FALSE
#> 29      grid           grid.group    4.2.0   closure     TRUE  function   FALSE
#> 30      grid          grid.stroke    4.2.0   closure     TRUE  function   FALSE
#> 31      grid             grid.use    4.2.0   closure     TRUE  function   FALSE
#> 32      grid           gridCoords    4.2.0   closure     TRUE  function   FALSE
#> 33      grid       gridGrobCoords    4.2.0   closure     TRUE  function   FALSE
#> 34      grid      gridGTreeCoords    4.2.0   closure     TRUE  function   FALSE
#> 35      grid            groupFlip    4.2.0   closure     TRUE  function   FALSE
#> 36      grid            groupGrob    4.2.0   closure     TRUE  function   FALSE
#> 37      grid          groupRotate    4.2.0   closure     TRUE  function   FALSE
#> 38      grid           groupScale    4.2.0   closure     TRUE  function   FALSE
#> 39      grid           groupShear    4.2.0   closure     TRUE  function   FALSE
#> 40      grid       groupTranslate    4.2.0   closure     TRUE  function   FALSE
#> 41      grid           strokeGrob    4.2.0   closure     TRUE  function   FALSE
#> 42      grid              useGrob    4.2.0   closure     TRUE  function   FALSE
#> 43      grid            useRotate    4.2.0   closure     TRUE  function   FALSE
#> 44      grid             useScale    4.2.0   closure     TRUE  function   FALSE
#> 45      grid         useTranslate    4.2.0   closure     TRUE  function   FALSE
#> 46      grid       viewportRotate    4.2.0   closure     TRUE  function   FALSE
#> 47      grid        viewportScale    4.2.0   closure     TRUE  function   FALSE
#> 48      grid    viewportTransform    4.2.0   closure     TRUE  function   FALSE
#> 49      grid    viewportTranslate    4.2.0   closure     TRUE  function   FALSE
#> 50     stats             psmirnov    4.2.0   closure     TRUE  function   FALSE
#> 51     stats             qsmirnov    4.2.0   closure     TRUE  function   FALSE
#> 52     stats             rsmirnov    4.2.0   closure     TRUE  function   FALSE
#> 53     utils              clrhash    4.2.0   closure     TRUE  function   FALSE
#> 54     utils              gethash    4.2.0   closure     TRUE  function   FALSE
#> 55     utils              hashtab    4.2.0   closure     TRUE  function   FALSE
#> 56     utils           is.hashtab    4.2.0   closure     TRUE  function   FALSE
#> 57     utils              maphash    4.2.0   closure     TRUE  function   FALSE
#> 58     utils              numhash    4.2.0   closure     TRUE  function   FALSE
#> 59     utils              remhash    4.2.0   closure     TRUE  function   FALSE
#> 60     utils              sethash    4.2.0   closure     TRUE  function   FALSE
#> 61     utils              typhash    4.2.0   closure     TRUE  function   FALSE
#>                                                                                                                                                            args
#> 1                                                                                                                                                          <NA>
#> 2  (x, n = 5L, min.n = n%/%3L, shrink.sml = 0.75, high.u.bias = 1.5,     u5.bias = 0.5 + 1.5 * high.u.bias, eps.correct = 0L, f.min = 2^-20,     bounds = TRUE)
#> 3                                                                                                                                             (x, mode = "any")
#> 4                                                                                                                                             (x, mode = "any")
#> 5                                                                                                                                                          <NA>
#> 6                                                                                                                                                           (x)
#> 7                                                                                                                                                           (x)
#> 8                                                                                                                                          (lang, unset = "en")
#> 9                                                                                                                                                   (fun, rule)
#> 10                                                                                                                                    (source, op, destination)
#> 11                                                                                                                                                           ()
#> 12                                                                                                                                                  (fun, type)
#> 13                                                                                                                                                          (x)
#> 14                                                                                                                                                          (x)
#> 15                                                                                                                                                 (ref, trans)
#> 16                                                                                                                          (x, type = c("alpha", "luminance"))
#> 17                                                                                                             (x, gp = gpar(), rule = c("winding", "evenodd"))
#> 18                                                                       (src, op = "over", dst = NULL, coords = TRUE, name = NULL,     gp = gpar(), vp = NULL)
#> 19                                                                                                                      (group, inverse = FALSE, device = TRUE)
#> 20                                                                                                                                     (group, inverse = FALSE)
#> 21                                                                                                                      (group, inverse = FALSE, device = TRUE)
#> 22                                                                                                                                                       (name)
#> 23                                                                                                                                                       (name)
#> 24                                                                                                                                                     (x, ...)
#> 25                                                                                                                                                     (x, ...)
#> 26                                                                       (src, op = "over", dst = NULL, coords = TRUE, name = NULL,     gp = gpar(), vp = NULL)
#> 27                                                                                                                                                        (...)
#> 28                                                                                                                                                        (...)
#> 29                                                                       (src, op = "over", dst = NULL, coords = TRUE, name = NULL,     gp = gpar(), vp = NULL)
#> 30                                                                                                                                                        (...)
#> 31                                                                              (group, transform = viewportTransform, name = NULL,     gp = gpar(), vp = NULL)
#> 32                                                                                                                                                       (x, y)
#> 33                                                                                                                                       (x, name, rule = NULL)
#> 34                                                                                                                                                    (x, name)
#> 35                                                                                                                               (flipX = FALSE, flipY = FALSE)
#> 36                                                                       (src, op = "over", dst = NULL, coords = TRUE, name = NULL,     gp = gpar(), vp = NULL)
#> 37                                                                                                                                       (r = 0, device = TRUE)
#> 38                                                                                                                                             (sx = 1, sy = 1)
#> 39                                                                                                                                             (sx = 0, sy = 0)
#> 40                                                                                                                                             (dx = 0, dy = 0)
#> 41                                                                                                                                                     (x, ...)
#> 42                                                                              (group, transform = viewportTransform, name = NULL,     gp = gpar(), vp = NULL)
#> 43                                                                                                                             (inverse = FALSE, device = TRUE)
#> 44                                                                                                                                            (inverse = FALSE)
#> 45                                                                                                                             (inverse = FALSE, device = TRUE)
#> 46                                                                                                                                       (group, device = TRUE)
#> 47                                                                                                                                       (group, device = TRUE)
#> 48                                                                                             (group, shear = groupShear(), flip = groupFlip(), device = TRUE)
#> 49                                                                                                                                       (group, device = TRUE)
#> 50                                       (q, sizes, z = NULL, two.sided = TRUE, exact = TRUE,     simulate = FALSE, B = 2000, lower.tail = TRUE, log.p = FALSE)
#> 51                                                                         (p, sizes, z = NULL, two.sided = TRUE, exact = TRUE,     simulate = FALSE, B = 2000)
#> 52                                                                                                                       (n, sizes, z = NULL, two.sided = TRUE)
#> 53                                                                                                                                                          (h)
#> 54                                                                                                                                     (h, key, nomatch = NULL)
#> 55                                                                                                                     (type = c("identical", "address"), size)
#> 56                                                                                                                                                          (x)
#> 57                                                                                                                                                     (h, FUN)
#> 58                                                                                                                                                          (h)
#> 59                                                                                                                                                     (h, key)
#> 60                                                                                                                                              (h, key, value)
#> 61                                                                                                                                                          (h)
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
