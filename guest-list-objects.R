#! Rscript
#

if (exists("try") && exists("traceback")) try(options(error = traceback)) # no traceback in 0.0

source("guest-functions.R")

mySetEnv(DISPLAY=":0")

rv <- getRVersion()
shortRversion <- paste(rv$major, rv$minor, sep = ".")
S4exists <- rv$major > 1 || (rv$major == 1 && rv$minor >= "4.0") # think doing string comparisons OK
if (S4exists) library(methods)

# zero-length data frame creation didn't work around 0.65
# and truncation removes class info
pkgData <- data.frame(
        name     = I(character(1)), 
        type     = I(character(1)),
        class    = I(character(1)),
        exported = logical(1),
        generic  = logical(1),
        args     = I(character(1)),
        package  = I(character(1)),
        priority = I(character(1)),
        Rversion = I(character(1))
      )

RHome <- myGetEnv("R_HOME")
if (RHome == "") RHome <- myGetEnv("RHOME")
if (RHome == "") RHome <- paste("/opt/R/", shortRversion, sep = "")
baseLibDir <- paste(RHome, "/library", sep = "")
# ip <- installed.packages()[, "Package"]
# baseLibDir <- paste("/opt/R/", shortRversion, "/lib/R/library", sep = "")
ip <- system(paste("ls", baseLibDir), intern = T)

hasPriorities <- exists("installed.packages") && 
  "priority" %in% names(formals(installed.packages))
if (hasPriorities) {
  basePackages <- installed.packages(priority = "base")
  basePackages <- basePackages[, "Package"]
  recommendedPackages <- installed.packages(priority = "recommended")
  # this happened in 2.9.0:
  if (shortRversion == "2.9.0") {
    recommendedPackagesMisspelled <- installed.packages(priority = "Recommended")
    recommendedPackages <- rbind(recommendedPackages, recommendedPackagesMisspelled)
  }
  recommendedPackages <- recommendedPackages[, "Package"]
  recommendedPackages <- c(recommendedPackages, "rcompgen") # for R 2.5.0, see NEWS
}

for (pkg in ip) {
  if (pkg ==  "Rprofile" || pkg == "LibIndex" || pkg == "translations" || 
      pkg == "R.css" || pkg == "index.html") next
  # as.numeric catches versions e.g. 0.7 in pre
  loadedOK <- if (rv$major < 1 && as.numeric(rv$minor) < 14) {
    TRUE # let's hope
  } else if (rv$major < 1 && as.numeric(rv$minor) < 60) {
    eval(parse(text = paste("require(", pkg, ")")))
  } else {
    library(pkg, character.only = T, logical.return = T)
  }
  if (! loadedOK) {
    warning(paste("Could not load", pkg))
    next
  }
  priority <- if (! hasPriorities) NA else {
    if (pkg %in% basePackages) {
      "base" 
    } else if (pkg %in% recommendedPackages) {
      "recommended"
    } else {
      NA
    }
  } 
  thisPkgData <- makeData(pkg, priority = priority)
  pkgData <- myRbind(pkgData, thisPkgData)
}

pkgData <- pkgData[-1, ] # remove first empty row
write.table(pkgData, 
        file = paste("docker-data/pkg_data-R-", shortRversion, ".csv", sep = ""),
        sep = ",",
        row.names = F,
        qmethod   = "double",
        col.names = T
      )
q("no")

