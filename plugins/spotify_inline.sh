#!/bin/bash

PLAYING=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)

if [ "$PLAYING" = "playing" ]; then
  TRACK=$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null)
  ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null)
  
  if [ -n "$TRACK" ] && [ -n "$ARTIST" ]; then
    sketchybar --set spotify.inline label="$TRACK - $ARTIST" drawing=on
  else
    sketchybar --set spotify.inline drawing=off
  fi
else
  sketchybar --set spotify.inline drawing=off
fi
