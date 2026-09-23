#!/bin/bash

# Each evercran image contains one or more R installations. For every version:
# 1. extract the function data as before;
# 2. render compiled help with that version of R, or copy older ready-made HTML;
# 3. record function aliases for the host to index after all images finish.

HTML_HELP=$1

for RVERSION in /opt/R/*; do
  RBIN="$RVERSION/bin/R"
  RBASE=$(basename "$RVERSION")
  RERR="errors/error-$RBASE.txt"

  RARGS="--no-restore --no-save -nosave"
  case $RBASE in
    0.49 | 0.50-a1 | 0.50-a4 ) RARGS="";;
    0.60* | 0.61* ) RARGS="-nosave";;
  esac

  # R 0.50 and 0.60 have suffixed installation directories, but report these
  # shorter version numbers in the package data.
  HELP_VERSION=$RBASE
  case $RBASE in
    0.50-a1 | 0.50-a4 ) HELP_VERSION="0.50";;
    0.60.0 ) HELP_VERSION="0.60";;
  esac
  VERSIONDIR="help-site/$HELP_VERSION"

  # R 2.10 and later store help in compiled databases. Pass the help flag to
  # the existing R invocation so guest-list-objects.R renders it before exit.
  COMPILED_HELP=false
  R_HELP_ARGS=""
  if [ "$HTML_HELP" = "--html-help" ] && \
      find "$RVERSION" -path "*/help/*.rdb" -type f | grep -q .; then
    COMPILED_HELP=true
    R_HELP_ARGS="--args --html-help"
  fi

  echo "Starting $RBIN"
  RV=$RVERSION DISPLAY=host.docker.internal:1 $RBIN \
      $RARGS $R_HELP_ARGS < guest-list-objects.R 1>"$RERR"

  [ "$HTML_HELP" = "--html-help" ] || continue
  mkdir -p "$VERSIONDIR"

  if [ "$COMPILED_HELP" = false ]; then
    # Earlier versions shipped HTML directly. The library moved several times,
    # so use the first historical location which exists.
    for LIBRARY in "$RVERSION/library" "$RVERSION/lib/R/library" \
        "$RVERSION/share/R/library"; do
      [ -d "$LIBRARY" ] && break
    done

    if [ -d "$LIBRARY" ]; then
      for PKGDIR in "$LIBRARY"/*; do
        [ -f "$PKGDIR/help/AnIndex" ] || continue
        [ -d "$PKGDIR/html" ] || continue
        PKG=$(basename "$PKGDIR")
        mkdir -p "$VERSIONDIR/$PKG"
        cp -R "$PKGDIR/html/." "$VERSIONDIR/$PKG/"
        awk -v package="$PKG" -F '\t' \
          'NF >= 2 { print package "\t" $1 "\t" $2 }' \
          "$PKGDIR/help/AnIndex" >> "$VERSIONDIR/aliases.tsv"
      done
    elif [ -f "$RVERSION/help/AnIndex" ] && [ -d "$RVERSION/html" ]; then
      # Some early versions have one base help directory rather than packages.
      mkdir -p "$VERSIONDIR/base"
      cp -R "$RVERSION/html/." "$VERSIONDIR/base/"
      awk -F '\t' 'NF >= 2 { print "base\t" $1 "\t" $2 }' \
        "$RVERSION/help/AnIndex" >> "$VERSIONDIR/aliases.tsv"
    fi

    if [ ! -s "$VERSIONDIR/aliases.tsv" ] && [ -d "$RVERSION/html/funs" ]; then
      # R 0.50 predates AnIndex and stores one HTML file per function.
      mkdir -p "$VERSIONDIR/base"
      for HTML in "$RVERSION/html/funs/"*.html "$RVERSION/html/funs/".*.html; do
        [ -f "$HTML" ] || continue
        TOPIC=$(basename "$HTML" .html)
        cp "$HTML" "$VERSIONDIR/base/"
        printf 'base\t%s\t%s\n' "$TOPIC" "$TOPIC" >> "$VERSIONDIR/aliases.tsv"
      done
    fi
  fi
done
