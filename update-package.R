
## UPDATE PROCEDURE
# version <- commandArgs(trailingOnly = TRUE)

# run ./host-run-on-evercran.sh

version <- "4.3.1.1"

if (length(version) != 1) {
  stop("Usage: Rscript update-package.R x.y.z.v")
}
r_version <- gsub("\\.\\d+$", "", version)

source("write-package-data.R")
devtools::install()
# check new data
print(table(rcheology::rcheology$Rversion))

rmarkdown::render("README.Rmd")
file.remove("README.html")
stop("Now update DESCRIPTION to ", version)
system(paste0("git commit -a --no-verify -m 'Updates for R ", r_version, "'"))

system("git push")

source("make-app-data.R")
rsconnect::deployApp("app")

# run checks:
devtools::check()
devtools::check_win_devel()
devtools::check_win_release()
devtools::check_mac_release()

# rhc <- rhub::check_for_cran()
rdc <- revdepcheck::revdep_check()

cat(sprintf("
# Now wait for checks. Also check it's passed appveyor.
# Check CRAN for previous check failures to fix:
# https://cran.r-project.org/web/checks/check_results_rcheology.html

# update cran-comments.md appropriately
# then 
Rscript -e 'devtools::release()'

# AFTER ACCEPTANCE
# tag release
rm CRAN-SUBMISSION
git tag -m \"Version %s on CRAN\" -a v%s
git push --tags

# reset revdepcheck
Rscript -e 'revdepcheck::revdep_reset()'

# And create github release titled %s to update r-universe
", version, version, version))
