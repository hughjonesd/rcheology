
## UPDATE PROCEDURE

# 1. Start docker
# 2. run ./host-run-on-evercran.sh (update to include latest version if nec)
# 3. edit 'version' below
# 4. run this script in a fresh R session

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

cat("
# Now wait for checks. Also check it's passed appveyor.
# Check CRAN for previous check failures to fix:
# https://cran.r-project.org/web/checks/check_results_rcheology.html

# update cran-comments.md appropriately
# then 
devtools::release()

# after acceptance, run post-acceptance.sh and enter the (full package) version
")
