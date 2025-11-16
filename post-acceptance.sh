#!/bin/bash

Rscript -e 'revdepcheck::revdep_reset()'
# This automatically deletes CRAN-SUBMISSION:
Rscript -e 'usethis::use_github_release()'

exit 0
