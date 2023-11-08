
## UPDATE PROCEDURE

# 1. run ./host-run-on-evercran.sh
# 2. edit 'version' below
# 3. run this script

version <- "4.3.2.0"

if (length(version) != 1) {
  stop("Usage: Rscript update-package.R x.y.z.v")
}
r_version <- sub("\\.\\d+$", "", version)

source("write-package-data.R")
devtools::install()
# check new data
print(table(rcheology::rcheology$Rversion))

devtools::build_readme()
file.remove("README.html")
system(sprintf("sed -e 's/Version:.*/Version: %s/' -i '' DESCRIPTION", version))
system("git add docker-data/*.csv")
system(sprintf("git commit -a --no-verify -m 'Updates for R %s'", r_version))
system("git push")

# update shinyapps app
source("make-app-data.R")
rsconnect::deployApp("app", forceUpdate = TRUE)

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
