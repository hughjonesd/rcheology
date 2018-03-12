
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

The data
--------

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

Package functions over time:

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

New functions in each version:

``` r
rvs <- as.character(sort(as.package_version(unique(rcheology$Rversion))))

fullname <- paste(rcheology$package, rcheology$name, sep = ":")

wrap <- function (char) paste(char, collapse = "\n")

for (i in seq(2, length(rvs))) {
  old <- fullname[rcheology$Rversion == rvs[i-1]]
  new <- fullname[rcheology$Rversion == rvs[i]]
  introduced <- setdiff(new, old)
  if (length(introduced) > 0) cat("New in ", rvs[i], ":\n", wrap(introduced), "\n")
  removed <- setdiff(old, new)
  if (length(removed) > 0) cat("Removed in ", rvs[i], ":\n", wrap(removed), "\n\n")
}
#> New in  3.1.0 :
#>  base:$.data.frame
#> base:La_version
#> base:OlsonNames
#> base:agrepl
#> base:all.equal.POSIXt
#> base:anyNA
#> base:anyNA.POSIXlt
#> base:anyNA.numeric_version
#> base:cospi
#> base:dontCheck
#> base:sinpi
#> base:tanpi
#> grid:current.parent
#> grid:current.rotation
#> grid:depth
#> grid:explode
#> grid:forceGrob
#> grid:grid.grep
#> grid:legendGrob
#> grid:resolveHJust
#> grid:resolveRasterSize
#> grid:resolveVJust
#> stats:confint.lm
#> stats:dummy.coef.lm
#> tools:buildVignette
#> tools:find_gs_cmd
#> utils:changedFiles
#> utils:fileSnapshot
#> utils:suppressForeignCheck 
#> Removed in  3.1.0 :
#>  base:all.equal.POSIXct
#> stats:TukeyHSD.aov
#> stats:aggregate.default
#> stats:anova.glm
#> stats:anova.glmlist
#> stats:anova.lm
#> stats:anova.lmlist
#> stats:anova.mlm
#> stats:deriv.default
#> stats:deriv.formula
#> stats:deriv3.default
#> stats:deriv3.formula
#> stats:diff.ts
#> stats:hatvalues.lm
#> stats:lines.ts
#> stats:model.frame.aovlist
#> stats:model.frame.glm
#> stats:model.frame.lm
#> stats:plot.TukeyHSD
#> stats:plot.density
#> stats:plot.lm
#> stats:plot.mlm
#> stats:plot.spec
#> stats:predict.mlm
#> stats:predict.poly
#> stats:print.anova
#> stats:print.density
#> stats:print.family
#> stats:print.formula
#> stats:print.ftable
#> stats:print.glm
#> stats:print.infl
#> stats:print.integrate
#> stats:print.lm
#> stats:print.logLik
#> stats:print.terms
#> stats:print.ts
#> stats:qqnorm.default
#> stats:quantile.default
#> stats:residuals.default
#> stats:rstandard.glm
#> stats:rstandard.lm
#> stats:rstudent.glm
#> stats:rstudent.lm
#> stats:summary.aovlist
#> stats:summary.infl
#> stats:summary.mlm
#> stats:terms.aovlist
#> stats:terms.default
#> stats:terms.terms 
#> 
#> New in  3.1.1 :
#>  utils:promptImport 
#> New in  3.1.2 :
#>  base:c.warnings
#> base:icuGetCollate
#> base:unique.warnings 
#> New in  3.1.3 :
#>  base:as.data.frame.noquote
#> base:pcre_config 
#> New in  3.2.0 :
#>  base:[.Dlist
#> base:[<-.numeric_version
#> base:all.equal.envRefClass
#> base:all.equal.environment
#> base:curlGetHeaders
#> base:debuggingState
#> base:dir.exists
#> base:dynGet
#> base:extSoftVersion
#> base:file.mode
#> base:file.mtime
#> base:file.size
#> base:forceAndCall
#> base:get0
#> base:is.na<-.numeric_version
#> base:isNamespaceLoaded
#> base:lengths
#> base:libcurlVersion
#> base:print.Dlist
#> base:returnValue
#> base:trimws
#> datasets:UScitiesD
#> grDevices:grSoftVersion
#> tcltk:tclVersion
#> tools:check_packages_in_dir_changes
#> tools:loadPkgRdMacros
#> tools:loadRdMacros
#> tools:toTitleCase
#> utils:hsearch_db
#> utils:hsearch_db_concepts
#> utils:hsearch_db_keywords 
#> New in  3.2.2 :
#>  tcltk:tkimage.delete
#> tcltk:tkimage.height
#> tcltk:tkimage.inuse
#> tcltk:tkimage.type
#> tcltk:tkimage.types
#> tcltk:tkimage.width
#> tcltk:ttkscale
#> tcltk:ttkspinbox 
#> Removed in  3.2.2 :
#>  tcltk:tkimage.cget
#> tcltk:tkimage.configure
#> tcltk:ttkimage 
#> 
#> New in  3.3.0 :
#>  base:[.table
#> base:c.difftime
#> base:chkDots
#> base:endsWith
#> base:grouping
#> base:startsWith
#> base:strrep
#> base:validEnc
#> base:validUTF8
#> methods:externalRefMethod
#> stats:sigma
#> tools:Rcmd
#> tools:langElts
#> tools:makevars_site
#> tools:makevars_user
#> tools:nonS3methods
#> utils:isS3method 
#> New in  3.3.1 :
#>  base:diff.difftime 
#> New in  3.3.2 :
#>  base:duplicated.warnings 
#> New in  3.4.0 :
#>  base:La_library
#> base:print.eigen
#> base:withAutoprint
#> methods:isRematched
#> tools:CRAN_check_details
#> tools:CRAN_check_results
#> tools:CRAN_memtest_notes
#> tools:CRAN_package_db
#> tools:check_packages_in_dir_details
#> tools:package_native_routine_registration_skeleton
#> tools:summarize_CRAN_check_status
#> utils:debugcall
#> utils:hasName
#> utils:isS3stdGeneric
#> utils:strcapture
#> utils:undebugcall 
#> New in  3.4.1 :
#>  tools:CRAN_check_issues
```

Argument changes:

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

for (i in seq(2, length(rvs))) {
  old <- rcheology %>% filter(Rversion == rvs[i-1])
  new <- rcheology %>% filter(Rversion == rvs[i])
  combined <- inner_join(old, new, by = c("name", "package"), suffix = c("_old", "_new"))
  args_changed <- combined %>% filter(args_old != args_new)
  if (nrow(args_changed) > 0){
    cat("Arguments changed in ", rvs[i], ":\n", wrap(args_changed$name), "\n\n")
  }
}
#> Arguments changed in  3.1.0 :
#>  Sys.timezone
#> all.equal.character
#> all.equal.factor
#> all.equal.list
#> all.equal.raw
#> as.data.frame.table
#> attr.all.equal
#> gl
#> namespaceImportFrom
#> pushBack
#> readLines
#> warning
#> current.viewport
#> grid.force
#> grid.layout
#> grid.legend
#> grid.revert
#> grid.show.layout
#> grid.show.viewport
#> KalmanForecast
#> KalmanLike
#> KalmanRun
#> KalmanSmooth
#> arima
#> loadings
#> makeARIMA
#> checkFF
#> summarize_check_packages_in_dir_results
#> vignetteEngine
#> rc.settings 
#> 
#> Arguments changed in  3.1.1 :
#>  dev.new
#> embedFonts
#> read.DIF
#> type.convert 
#> 
#> Arguments changed in  3.1.2 :
#>  as.Date.character 
#> 
#> Arguments changed in  3.2.0 :
#>  anyNA
#> anyNA.POSIXlt
#> anyNA.numeric_version
#> as.list.environment
#> dget
#> file.info
#> match.call
#> rbind.data.frame
#> url
#> pairs.default
#> kmeans
#> summarize_check_packages_in_dir_depends
#> testInstalledBasic
#> URLencode
#> read.fwf 
#> 
#> Arguments changed in  3.2.1 :
#>  as.character.srcref
#> nchar
#> nzchar 
#> 
#> Arguments changed in  3.2.2 :
#>  removeClass
#> poly
#> polym
#> capture.output
#> chooseBioCmirror
#> chooseCRANmirror 
#> 
#> Arguments changed in  3.2.3 :
#>  interpSpline
#> splineDesign 
#> 
#> Arguments changed in  3.2.4 :
#>  provideDimnames
#> rbind.data.frame
#> shQuote 
#> 
#> Arguments changed in  3.3.0 :
#>  all.equal.numeric
#> as.data.frame.list
#> findInterval
#> gzcon
#> namespaceImport
#> namespaceImportFrom
#> nchar
#> order
#> qr.R
#> regexec
#> pdf
#> postscript
#> recordPlot
#> replayPlot
#> xfig
#> assignMethodsMetaData
#> detectCores
#> aggregate.data.frame
#> cmdscale
#> ppoints
#> toeplitz
#> loadPkgRdMacros
#> package_dependencies
#> available.packages
#> getS3method 
#> 
#> Arguments changed in  3.3.1 :
#>  text.default 
#> 
#> Arguments changed in  3.3.2 :
#>  c
#> removeClass 
#> 
#> Arguments changed in  3.4.0 :
#>  debug
#> debugonce
#> droplevels.data.frame
#> droplevels.factor
#> format.summaryDefault
#> isSymmetric.matrix
#> isdebugged
#> order
#> print.POSIXct
#> print.POSIXlt
#> print.summaryDefault
#> sample.int
#> split.default
#> summary.default
#> summary.factor
#> sys.source
#> tapply
#> try
#> undebug
#> unix.time
#> compile
#> median
#> median.default
#> smooth.spline
#> dump.frames
#> strOptions 
#> 
#> Arguments changed in  3.4.1 :
#>  summarize_CRAN_check_status
```
