#!/bin/bash

for RVERSION in /opt/R/*; do
  RBIN="$RVERSION/bin/R"
  
  RBASE=$(basename $RVERSION)
  RERR="errors/error-$RBASE.txt"
  
  RARGS="--no-restore --no-save -nosave"
  case $RBASE in
    0.49 | 0.50-a1 | 0.50-a4 ) RARGS="";;
    0.60* | 0.61* ) RARGS="-nosave";;
  esac

  echo "Starting $RBIN"
  if find "$RVERSION" -path "*/help/*.rdb" -type f | grep -q .; then
    RV=$RVERSION DISPLAY=host.docker.internal:1 \
      RCHEOLOGY_HELP_OUTPUT_FILE="docker-data/help-R-$RBASE.RData" \
      $RBIN $RARGS < guest-list-objects.R 1>$RERR
    continue
  fi

  RV=$RVERSION DISPLAY=host.docker.internal:1 \
    $RBIN $RARGS < guest-list-objects.R 1>$RERR

  STAGING="legacy-help-$RBASE"
  rm -rf "$STAGING"
  mkdir -p "$STAGING"

  if [ -d "$RVERSION/library" ]; then
    LIBRARY="$RVERSION/library"
  elif [ -d "$RVERSION/lib/R/library" ]; then
    LIBRARY="$RVERSION/lib/R/library"
  elif [ -d "$RVERSION/share/R/library" ]; then
    LIBRARY="$RVERSION/share/R/library"
  else
    LIBRARY=""
  fi

  if [ -n "$LIBRARY" ]; then
    for PKGDIR in "$LIBRARY"/*; do
      [ -f "$PKGDIR/help/AnIndex" ] || continue
      PKG=$(basename "$PKGDIR")
      mkdir -p "$STAGING/$PKG"
      cp -R "$PKGDIR/help" "$STAGING/$PKG/"
      if [ -d "$PKGDIR/html" ]; then
        cp -R "$PKGDIR/html" "$STAGING/$PKG/"
      fi
    done
  elif [ -f "$RVERSION/help/AnIndex" ]; then
    mkdir -p "$STAGING/base"
    cp -R "$RVERSION/help" "$STAGING/base/"
    if [ -d "$RVERSION/html" ]; then
      cp -R "$RVERSION/html" "$STAGING/base/"
    fi
  fi

  # R 0.50 predates package help indexes. Its generated function pages live
  # directly under html/funs.
  if [ -z "$(ls -A "$STAGING")" ] && [ -d "$RVERSION/html/funs" ]; then
    mkdir -p "$STAGING/base/help" "$STAGING/base/html"
    for HTML in "$RVERSION/html/funs/"*.html "$RVERSION/html/funs/".*.html; do
      [ -f "$HTML" ] || continue
      TOPIC=$(basename "$HTML" .html)
      cp "$HTML" "$STAGING/base/html/"
      printf '%s\t%s\n' "$TOPIC" "$TOPIC" >> "$STAGING/base/help/AnIndex"
    done
  fi

  tar -czf "docker-data/help-R-$RBASE.tar.gz" "$STAGING"
  rm -rf "$STAGING"
done
