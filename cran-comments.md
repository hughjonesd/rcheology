Update for R 4.0.0

## Test environments
* local OS X install, R 3.6.2
* ubuntu 14.04 (on travis-ci), R 4.0.0
* windows (on appveyor), R 4.0.0
* windows and linux using rhub::check_for_cran(), R-devel and R-release

## R CMD check results

0 errors | 0 warnings | 0 notes

There was one obviously false positive NOTE in a single rhub check:

Found the following (possibly) invalid URLs:
    URL: https://cran.r-project.org/package=rversions
      From: man/rcheology-package.Rd
      Status: Error
      Message: libcurl error code 52:
        	Empty reply from server

This worked fine for all other checks.

