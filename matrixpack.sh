#!/bin/bash
# Usage
# matrixpack token homeserver directory...
# 
# Pack name is the directory name
# Sticker name is the file name
# /!\ Token is a sensitive information

# UTILITY FUNCTIONS
function require {
  hash $1 2>/dev/null || {
    echo >&2 "Error: '$1' is required, but was not found."; exit 1;
  }
}

function slugify () {
    echo "$1" | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr A-Z a-z
}

# Display usage funtion
display_usage (){
    echo -e "\nUsage : ./matrixpack.sh token homeserver directory\n"
}

# Erase http:// or https:// if added in the homeserver
slug_homeserver() {
    echo "$1" | iconv -c -t ascii//TRANSLIT | sed -E 's/^http:\/\/|^https:\/\///g' | sed -E 's/^-+|-+$//g'
}

# COMMON REQUIRED BINARIES
require convert
require montage
require identify
require python
require curl
require sed
require tr

# Checking params
if test $# -lt 3 ; then
  echo 1>&2 "$0:FATAL: invalid argument number (expected 3)"
  display_usage
  exit 1
fi

# Setting variables
token=$1
homeserver=$(slug_homeserver $2)

# Checking if the homeserver exist.
# If the homeserver does not exist, the file headers is not created
curl "https://$homeserver" -I -o headers -s
if test -f "headers"; then
    rm headers
else
    echo 1>&2 "$0:FATAL: The homeserver \"$2\" is incorrect."
    exit 1
fi

# Checking if the token exist.
# Save the error value on file "headers" and 
# evaluate it to verify the token
curl -s -X POST  "https://$homeserver/_matrix/media/r0/upload?access_token=$token" | python3 -c "import sys, json; print(json.load(sys.stdin)['errcode'])" >> headers
while read line; do
    if [[ ($line == "M_UNKNOWN") ]]
    then
        rm headers
    else if [[ ($line == "M_UNKNOWN_TOKEN") ]]
    then
        echo "$0:ERROR: The token provided is incorrect or does not exist in this homeserver"
        rm headers
        exit 1
    else
        echo "$0:ERROR: Not yet implemented error"
        exit 1
    fi
    fi
done < headers

for i in "$@"
do
  if [ -d "$i" ]; then

    # Changing directory to work directly in it
    cd "$i"
    dir=$(pwd)
    packname=${dir##*/}
    slug=$(slugify "$packname")

    # Printing informations
    echo -e "Creating sticker pack : \033[94;1m$packname\033[0m\nhomeserver=\033[94m$homeserver\033[0m\noutput=\033[94m$slug\033[0m"

    # Making result folder
    if ! [ -d $slug ]; then mkdir $slug; fi
    if ! [ -d "$slug/tmp" ]; then mkdir "$slug/tmp"; fi
    echo -n "{\"title\":\"$packname\",\"id\":\"$slug\",\"stickers\":[" > "$slug/$slug.json"

    first=""
    for f in *
    do
      # Ignore folders
      if [ -f "$f" ]; then

        # Resizing large images
        width=$(identify -format "%w" "$f"[0])> /dev/null
        height=$(identify -format "%h" "$f"[0])> /dev/null
        if [ $width -gt 256 ]; then
          width="256";
        fi
        if [ $height -gt 256 ]; then
          height="256";
        fi

        echo -n "$f : "
        type="png"
        opts="-type TrueColor PNG32:"

        # Gif
        if [[ "$f" == *.gif ]]; then
          type="gif"
          opts=""
        fi

        # Erase the extension of the image
        sticker_name=$(echo "$f" | cut -f 1 -d '.')

        # Trim, resize and remove indexed palette from image
        echo -n "trimming and resizing"
        convert "$f" -bordercolor none -border 1 "$slug/tmp/$f.$type"
        echo -n "."
        convert "$slug/tmp/$f.$type" -trim +repage "$slug/tmp/$f.$type"
        echo -n "."
        convert -background none -gravity center "$slug/tmp/$f.$type" -resize "${width}x$height" $opts"$slug/tmp/$f.$type"
        echo -ne ". \033[92mdone\033[0m! "
        
        # First item in array
        echo -n "$first" >> "$slug/$slug.json"
        
        # Uploading image
        echo -n "uploading."
        mxc=$(curl -s -X POST -H "Content-Type: image/$type" --data-binary "@$slug/tmp/$f.$type" "https://$homeserver/_matrix/media/r0/upload?access_token=$token" | python -c "import sys, json; print(json.load(sys.stdin)['content_uri'])")
        echo -n "."

        # Calculating 128x128> format
        convert "$slug/tmp/$f.$type" -resize "128x128" "$slug/tmp/size"
        width=$(identify -format "%w" "$slug/tmp/size"[0])> /dev/null
        height=$(identify -format "%h" "$slug/tmp/size"[0])> /dev/null

        # Appending to json
        echo -n "{\"body\":\"$sticker_name\",\"info\":{\"mimetype\":\"image/$type\",\"h\":$height,\"w\":$width,\"thumbnail_url\":\"$mxc\"},\"msgtype\":\"m.sticker\",\"url\":\"$mxc\",\"id\":\"$packname-$sticker_name\"}" >> "$slug/$slug.json"
        first=","
        echo -e ". \033[92msuccess\033[0m!"
      fi
    done
    
    rm "$slug/tmp/size"
    montage "$slug/tmp/*"[0] -background none "$slug/preview.png"
    rm -r "$slug/tmp"
    echo -ne "# $packname  \n![Preview of $packname](preview.png)" > "$slug/README.md"
    echo -n "]}" >> "$slug/$slug.json"
    cd - > /dev/null
    echo -e "\033[92;1mPack successfully created!\n\033[0mCheck \033[94;1m$dir/$slug \033[0mfor output"

  fi
done
