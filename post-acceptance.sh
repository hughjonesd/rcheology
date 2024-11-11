#!/bin/bash

# After CRAN acceptance
# tag release

VERSION=$(grep '^Version:' DESCRIPTION | sed -e 's/Version: *//')
CRANCOMMIT=$(cat CRAN-SUBMISSION)

if [[ -z $VERSION || -z $CRANCOMMIT ]]; then
  echo "VERSION or CRANCOMMIT was empty"
  echo "VERSION: '$VERSION'"
  echo "CRANCOMMIT: '$CRANCOMMIT'"
  exit 1
fi

git tag -m "Version $VERSION on CRAN" -a v$VERSION $CRANCOMMIT
git push --tags
rm CRAN-SUBMISSION

Rscript -e 'revdepcheck::revdep_reset()'
Rscript -e 'usethis::use_github_release()'

exit 0
