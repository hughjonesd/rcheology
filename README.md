
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

The latest R version covered is 4.3.0.

You can view the data online in a [Shiny
app](https://hughjonesd.shinyapps.io/rcheology/).

## Installing

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

rcheology[rcheology$name == "kmeans" & rcheology$Rversion %in% c("1.0.1", "1.9.0", "2.1.0", "3.0.2", "3.2.0", "4.0.2"), ]
#>        package   name Rversion    type exported    class generic
#> 214365     mva kmeans    1.0.1 closure     TRUE     <NA>   FALSE
#> 234993   stats kmeans    1.9.0 closure     TRUE function   FALSE
#> 234997   stats kmeans    2.1.0 closure     TRUE function   FALSE
#> 235036   stats kmeans    3.0.2 closure     TRUE function   FALSE
#> 235041   stats kmeans    3.2.0 closure     TRUE function   FALSE
#> 235066   stats kmeans    4.0.2 closure     TRUE function   FALSE
#>                                                                                                                              args
#> 214365                                                                                                (x, centers, iter.max = 10)
#> 234993                                                                                                (x, centers, iter.max = 10)
#> 234997                  (x, centers, iter.max = 10, nstart = 1, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"))
#> 235036   (x, centers, iter.max = 10, nstart = 1, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
#> 235041 (x, centers, iter.max = 10L, nstart = 1L, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
#> 235066 (x, centers, iter.max = 10L, nstart = 1L, algorithm = c("Hartigan-Wong",     "Lloyd", "Forgy", "MacQueen"), trace = FALSE)
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
#>      package                    name Rversion    type exported    class generic
#> 1       base           .check_tzones    4.3.0 closure     TRUE function   FALSE
#> 2       base        .formula2varlist    4.3.0 closure     TRUE function   FALSE
#> 3       base             $<-.POSIXlt    4.3.0 closure     TRUE function   FALSE
#> 4       base                array2DF    4.3.0 closure     TRUE function   FALSE
#> 5       base          balancePOSIXlt    4.3.0 closure     TRUE function   FALSE
#> 6       base         chooseOpsMethod    4.3.0 closure     TRUE function   FALSE
#> 7       base chooseOpsMethod.default    4.3.0 closure     TRUE function   FALSE
#> 8       base       is.finite.POSIXlt    4.3.0 closure     TRUE function   FALSE
#> 9       base     is.infinite.POSIXlt    4.3.0 closure     TRUE function   FALSE
#> 10      base          is.nan.POSIXlt    4.3.0 closure     TRUE function   FALSE
#> 11      base             nameOfClass    4.3.0 closure     TRUE function   FALSE
#> 12      base     nameOfClass.default    4.3.0 closure     TRUE function   FALSE
#> 13      base           R_compiled_by    4.3.0 closure     TRUE function   FALSE
#> 14      base          unCfillPOSIXlt    4.3.0 builtin     TRUE function      NA
#> 15 grDevices             embedGlyphs    4.3.0 closure     TRUE function   FALSE
#> 16 grDevices             glyphAnchor    4.3.0 closure     TRUE function   FALSE
#> 17 grDevices               glyphFont    4.3.0 closure     TRUE function   FALSE
#> 18 grDevices           glyphFontList    4.3.0 closure     TRUE function   FALSE
#> 19 grDevices             glyphHeight    4.3.0 closure     TRUE function   FALSE
#> 20 grDevices       glyphHeightBottom    4.3.0 closure     TRUE function   FALSE
#> 21 grDevices               glyphInfo    4.3.0 closure     TRUE function   FALSE
#> 22 grDevices               glyphJust    4.3.0 closure     TRUE function   FALSE
#> 23 grDevices              glyphWidth    4.3.0 closure     TRUE function   FALSE
#> 24 grDevices          glyphWidthLeft    4.3.0 closure     TRUE function   FALSE
#> 25      grid               glyphGrob    4.3.0 closure     TRUE function   FALSE
#> 26      grid              grid.glyph    4.3.0 closure     TRUE function   FALSE
#> 27      grid                isClosed    4.3.0 closure     TRUE function   FALSE
#> 28     stats               toeplitz2    4.3.0 closure     TRUE function   FALSE
#> 29     tools         as.Rconcordance    4.3.0 closure     TRUE function   FALSE
#> 30     tools       followConcordance    4.3.0 closure     TRUE function   FALSE
#> 31     tools        matchConcordance    4.3.0 closure     TRUE function   FALSE
#> 32     utils                .AtNames    4.3.0 closure     TRUE function   FALSE
#> 33     utils             findMatches    4.3.0 closure     TRUE function   FALSE
#>                                                                                                                                     args
#> 1                                                                                                                                  (...)
#> 2                                                                                   (formula, data, warnLHS = TRUE, ignoreLHS = warnLHS)
#> 3                                                                                                                       (x, name, value)
#> 4                                     (x, responseName = "Value", sep = "", base = list(LETTERS),     simplify = TRUE, allowLong = TRUE)
#> 5                                                                                                 (x, fill.only = FALSE, classed = TRUE)
#> 6                                                                                                            (x, y, mx, my, cl, reverse)
#> 7                                                                                                            (x, y, mx, my, cl, reverse)
#> 8                                                                                                                                    (x)
#> 9                                                                                                                                    (x)
#> 10                                                                                                                                   (x)
#> 11                                                                                                                                   (x)
#> 12                                                                                                                                   (x)
#> 13                                                                                                                                    ()
#> 14                                                                                                                                   (x)
#> 15                                                                              (file, glyphInfo, outfile = file, options = character())
#> 16                                                                                                                        (value, label)
#> 17                                                                                     (file, index, family, weight, style, PSname = NA)
#> 18                                                                                                                                 (...)
#> 19                                                                                              (h, label = "height", bottom = "bottom")
#> 20                                                                                                                            (h, label)
#> 21                                                       (id, x, y, font, size, fontList, width, height, hAnchor,     vAnchor, col = NA)
#> 22                                                                                                                           (just, ...)
#> 23                                                                                                   (w, label = "width", left = "left")
#> 24                                                                                                                            (w, label)
#> 25 (glyphInfo, x = 0.5, y = 0.5, default.units = "npc",     hjust = "centre", vjust = "centre", gp = gpar(), vp = NULL,     name = NULL)
#> 26                                                                                                                                 (...)
#> 27                                                                                                                              (x, ...)
#> 28                                                                   (x, nrow = length(x) + 1L - ncol, ncol = length(x) +     1L - nrow)
#> 29                                                                                                                              (x, ...)
#> 30                                                                                                        (concordance, prevConcordance)
#> 31                                                                                                                (linenum, concordance)
#> 32                                                                                                                          (x, pattern)
#> 33                                                                                                              (pattern, values, fuzzy)
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
