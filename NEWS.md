
# Development version

* Completely new build infrastructure using 
  [r-lib/evercran](https://github.com/r-lib/evercran).
  - Data is extended back to R version 0.62.3.
  - Recommended packages are now recorded.
  - Versions 2.15.1-w and 3.2.4-revised are now NOT recorded in the dataset.
  - Versions 3.0.1 and 3.0.3 ARE now recorded.
  - `last.warning` and `.Last.sys` are not recorded in the dataset for some
    R versions.
  - The class of `as.array` is recorded as `standardGeneric` rather than
    `function` in R 2.9.0 to 2.13.1.
  - Package `tcltk` is not recorded for 1.x versions. Working on a fix....
    
* Links in the Shiny app now go to hughjonesd/r-help, which provides help pages
  for all versions of R from 0.60 onwards.


# rcheology 4.3.1.0

* New data for R 4.3.1


# rcheology 4.3.0.0

* New data for R 4.3.0


# rcheology 4.2.3.0

* New data for R 4.2.3


# rcheology 4.2.2.0

* New data for R 4.2.2


# rcheology 4.2.1.0

* New data for R 4.2.1
* Build using focal not bionic


# rcheology 4.2.0.0

* New data for R 4.2.0


# rcheology 4.1.3.0

* New data for R 4.1.3


# rcheology 4.1.2.0

* New data for R 4.1.2


# rcheology 4.1.1.0

* New data for R 4.1.1


# rcheology 4.1.0.0

* New data for R 4.1.0


# rcheology 4.0.5.0

* New data for R 4.0.5


# rcheology 4.0.4.0

* New data for R 4.0.4


# rcheology 4.0.3.0

* New data for R 4.0.3


# rcheology 4.0.2.0

* New data for R 4.0.2


# rcheology 4.0.1.0

* New data for R 4.0.1
* Compact display, new "first version" & "last version" columns in Shiny app

# rcheology 4.0.0.0

* New data for R 4.0.0
* Congratulations to the R Core Team, and everyone who made R what it is today!

# rcheology 3.6.3.0

* New data for R 3.6.3

# rcheology 3.6.2.0

* New data for R 3.6.2

# rcheology 3.6.1.0

* New data for R 3.6.1

# rcheology 3.6.0.0

* New data for R 3.6.0

# rcheology 3.5.3.0

* New data for R 3.5.3
* Update `Rversions` data

# rcheology 3.5.2.0

* New data for R 3.5.2

# rcheology 3.5.1.1

* Include R functions from R 1.0.1 onwards. Compiled on Debian Woody and Sarge.
* Removed releases of "recommended" packages from the Rversions data frame.
* Include objects whose names start with a `.`.
* New column "exported" reports whether object was found in `getNamespaceExports()`.

# rcheology 3.5.1.0

* Added a `NEWS.md` file to track changes to the package.
