
## UPDATE PROCEDURE

# 1. Start docker
# 2. Run a bash shell 
#   - bash matters because of allowing spaces in variables
# 3. Start Xquartz (or windows equivalent) and run 'xhost +' in a separate terminal
# 4. Update host-run-on-evercran.sh to include "run_image x.y.z", if necessary
# 5. In the bash shell, either:
#   - run ./host-run-on-evercran.sh to regenerate data for all R versions;
#   - Or, source host-functions.sh and run run_image x.y.z
# 6. edit 'version' below. 
#   - Usually this should be the latest R version, with an extra zero.
# 7. run this script in a fresh R session.
#   - Note that the script is interactive

version <- "4.5.2.0"

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
rsconnect::deployApp("app", forceUpdate = TRUE, appName = "rcheology")

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

# update cran-comments.md and NEWS.md appropriately, commit and push
# then 
devtools::release()


# after acceptance, run ./post-acceptance.sh 
# - NB again, this needs bash
# - NB: check contents of CRAN-SUBMISSION, you may need to rewrite post-acceptance.sh
#   or just let use_github_release() do it for you, it seems to create the tag
#  on github and can be pulled in
")
