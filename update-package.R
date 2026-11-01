
## UPDATE PROCEDURE

# Daily snapshots are handled separately by GitHub Actions and do not change
# this release procedure.

# 1. Start docker
# 2. Run a bash shell 
#   - bash matters because of allowing spaces in variables
# 3. For old R versions only, start Xquartz (or windows equivalent).
# 4. Update host-run-on-evercran.sh to include "run_image x.y.z", if necessary
# 5. In the bash shell, either:
#   - run ./host-run-on-evercran.sh to regenerate data for all R versions;
#   - Or, source host-functions.sh and run run_image x.y.z
# 6. edit 'version' below. 
#   - Usually this should be the latest R version, with an extra zero.
# 7. run this script in a fresh R session.
# 8. Review NEWS.md and the generated files before publishing.

version <- "4.6.2.0"

r_version <- sub("\\.\\d+$", "", version)

source("write-package-data.R")
stopifnot(
  all(rcheology$status == "released"),
  r_version %in% rcheology$Rversion,
  r_version %in% Rversions$Rversion
)
desc::desc_set_version(version)
devtools::install()
# check new data
print(table(rcheology::rcheology$Rversion))

devtools::build_readme()
file.remove("README.html")

# Prepare app data locally. Deployment waits for the final review below.
source("make-app-data.R")

devtools::check()

cat("
# STOP: review NEWS.md, README.md, the data changes, and check results.
# Nothing has been published. After approving the release, run the commands below.

")

# Run separately after the final review:
# rsconnect::deployApp("app", forceUpdate = TRUE, appName = "rcheology")
# system("git add docker-data/*.csv")
# system("git add app/rcheology-app-data.RData")
# system(sprintf("git commit -a -m 'Updates for R %s'", r_version))
# system("git push")
# usethis::use_github_release()
# Verify the GitHub release and the package version on r-universe.
