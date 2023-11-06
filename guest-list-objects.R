#! Rscript
#

if (exists("try") && exists("traceback")) try(options(error = traceback)) # no traceback in 0.0

source("guest-functions.R")

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
        Rversion = I(character(1))
      )

RHome <- myGetEnv("R_HOME")
if (RHome == "") RHome <- myGetEnv("RHOME")
baseLibDir <- paste(RHome, "/library", sep = "")
# ip <- installed.packages()[, "Package"]
# baseLibDir <- paste("/opt/R/", shortRversion, "/lib/R/library", sep = "")
ip <- system(paste("ls", baseLibDir), intern = T)

for (pkg in ip) {
  if (pkg %in% c("Rprofile", "LibIndex")) next
  loadedOK <- if (rv$major < 1 && rv$minor < "60") {
    eval(parse(text = paste("require(", pkg, ")")))
  } else {
    library(pkg, character.only = T, logical.return = T)
  }
  if (! loadedOK) {
    warning(paste("Could not load", pkg))
    next
  }
  thisPkgData <- makeData(pkg)
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

