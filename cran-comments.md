Update for R 4.0.3

## Test environments
* local OS X install, R 4.0.3
* ubuntu (on travis-ci), R-oldrel, R-release, R-devel
* windows (on appveyor), R 4.0.2-patched
* windows and linux using rhub::check_for_cran(), R-devel and R-release
* windows on win-builder, R-devel and R-release

## R CMD check results

* Win-builder R-devel gave a NOTE about https://hughjonesd.shinyapps.io/rcheology/;
  IMHO a false positive.
* Fine on all other platforms.

## Reverse dependencies

* hutils: fine.
