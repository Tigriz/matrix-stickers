#!/bin/bash

GIT_URL="https://git.iiens.net/Tigriz/matrix-stickers/-/tree/master/packs"
HTML_FILE_DEST="previews.html"
touch "$HTML_FILE_DEST"

echo '<!DOCTYPE html>' >"$HTML_FILE_DEST"
echo '<style type="text/css">div:target {background: antiquewhite}</style>' >>"$HTML_FILE_DEST"
echo '<html style="margin: 0; padding: 0;">' >>"$HTML_FILE_DEST"
echo '<body style="margin: 0; padding: 0;">' >>"$HTML_FILE_DEST"

echo '<div style="position: sticky; background: #fff; margin: 0; top: 0; padding: 10px; border-bottom: 1px solid black;">' >>"$HTML_FILE_DEST"
echo '<h1>Liste des packs</h1>' >>"$HTML_FILE_DEST"

separator=""
for pack in *; do
  if [ -d "$pack" ]; then
    echo "$separator<a href=\"#$pack\">$pack</a>" >>"$HTML_FILE_DEST"
    separator=" | "
  fi
done
echo '</div>' >>"$HTML_FILE_DEST"

separator=""
for pack in *; do
  if [ -d "$pack" ]; then
    echo "$separator" >>"$HTML_FILE_DEST"
    echo "<div id=\"$pack\" style=\"padding: 0 10px; scroll-margin-top: 300px;\">" >>"$HTML_FILE_DEST"
    echo "<h2><a href=\"$GIT_URL/$pack\" target=\"_blank\">$pack ↗</a></h2>" >>"$HTML_FILE_DEST"
    echo "<img src=\"$pack/preview.png\" />" >>"$HTML_FILE_DEST"
    echo "</div>" >>"$HTML_FILE_DEST"
    separator='<hr>'
  fi
done

echo "</body>" >>"$HTML_FILE_DEST"
echo "</html>" >>"$HTML_FILE_DEST"
