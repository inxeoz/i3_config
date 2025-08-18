#!/bin/bash

IMG="$HOME/.Shareable/inxeozss.png"
if [ ! -f "$IMG" ]; then
    notify-send "No image in $IMG"
    exit 1
fi

xclip -selection clipboard -t image/png < "$IMG"
# notify-send "Copied $IMG to clipboard"
