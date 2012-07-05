#!/bin/sh
# Displays a desktop notification using Growl (OS X) or libnotify (Linux).

icon=$1
message=$2
title=$3

which growlnotify && growlnotify --image "$icon" -m "$message" "$title" || \
which notify-send && notify-send --hint=int:transient:1 "$title" "$message" -i "$icon"
