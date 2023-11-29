
# After CRAN acceptance
# tag release

VERSION=$(grep '^Version:' DESCRIPTION | sed -e 's/Version: *//')
CRANCOMMIT=$(cat CRAN-SUBMISSION)

git tag -m "Version $VERSION on CRAN" -a v$VERSION $CRANCOMMIT
git push --tags
rm CRAN-SUBMISSION

# reset revdepcheck
Rscript -e 'revdepcheck::revdep_reset()'

VERSION=$VERSION Rscript -e '
version = Sys.getenv("VERSION")
gh::gh("POST /repos/hughjonesd/rcheology/releases", 
       name = version,
       tag_name = paste0("v", version),
       body = sprintf("Version %s on CRAN", version))
'



