
## UPDATE PROCEDURE

# 1. Start docker
# 2. Run a bash shell 
#   - bash matters because of allowing spaces in variables
# 3. Start Xquartz (or windows equivalent) and run 'xhost +' in a separate terminal
# 4. run ./host-run-on-evercran.sh 
#   - update the script to include the latest R version, if necessary
# 5. edit 'version' below. 
#   - Usually this should be the latest R version, with an extra zero.
# 6. run this script in a fresh R session

version <- "4.4.0.0"

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

# update shinyapps app
source("make-app-data.R")
rsconnect::deployApp("app", forceUpdate = TRUE)

system("git add docker-data/*.csv")
system("git add app/rcheology-app-data.RData")
system(sprintf("git commit -a --no-verify -m 'Updates for R %s'", r_version))
system("git push")

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

# update cran-comments.md and NEWS.md appropriately and commit
# then 
devtools::release()

# after acceptance, run post-acceptance.sh
")
