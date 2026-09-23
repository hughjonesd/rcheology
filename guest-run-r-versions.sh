#!/bin/bash

HTML_HELP=$1

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
  HELPARGS=""
  if [ "$HTML_HELP" = "--html-help" ] && \
      find "$RVERSION" -path "*/help/*.rdb" -type f | grep -q .; then
    HELPARGS="--args --html-help"
  fi
  RV=$RVERSION DISPLAY=host.docker.internal:1 $RBIN \
      $RARGS $HELPARGS < guest-list-objects.R 1>$RERR

  if [ "$HTML_HELP" != "--html-help" ]; then
    continue
  fi
  if [ -n "$HELPARGS" ]; then
    continue
  fi

  HELP_VERSION=$RBASE
  case $RBASE in
    0.50-a1 | 0.50-a4 ) HELP_VERSION="0.50";;
    0.60.0 ) HELP_VERSION="0.60";;
  esac
  VERSIONDIR="help-site/$HELP_VERSION"
  mkdir -p "$VERSIONDIR"
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
      [ -d "$PKGDIR/html" ] || continue
      PKG=$(basename "$PKGDIR")
      mkdir -p "$VERSIONDIR/$PKG"
      cp -R "$PKGDIR/html/." "$VERSIONDIR/$PKG/"
      awk -v package="$PKG" -F '\t' \
        'NF >= 2 { print package "\t" $1 "\t" $2 }' \
        "$PKGDIR/help/AnIndex" >> "$VERSIONDIR/aliases.tsv"
    done
  elif [ -f "$RVERSION/help/AnIndex" ] && [ -d "$RVERSION/html" ]; then
    mkdir -p "$VERSIONDIR/base"
    cp -R "$RVERSION/html/." "$VERSIONDIR/base/"
    awk -F '\t' 'NF >= 2 { print "base\t" $1 "\t" $2 }' \
      "$RVERSION/help/AnIndex" >> "$VERSIONDIR/aliases.tsv"
  fi

  if [ ! -s "$VERSIONDIR/aliases.tsv" ] && [ -d "$RVERSION/html/funs" ]; then
    mkdir -p "$VERSIONDIR/base"
    for HTML in "$RVERSION/html/funs/"*.html "$RVERSION/html/funs/".*.html; do
      [ -f "$HTML" ] || continue
      TOPIC=$(basename "$HTML" .html)
      cp "$HTML" "$VERSIONDIR/base/"
      printf 'base\t%s\t%s\n' "$TOPIC" "$TOPIC" >> "$VERSIONDIR/aliases.tsv"
    done
  fi
done
