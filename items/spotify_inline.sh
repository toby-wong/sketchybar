#!/bin/bash

spotify_inline=(
  script="$PLUGIN_DIR/spotify_inline.sh"
  label.font="$FONT:Regular:12.0"
  label.max_chars=50
  update_freq=1
  position=right
)

sketchybar --add item spotify.inline right \
           --set spotify.inline "${spotify_inline[@]}" \
           --subscribe spotify.inline com.spotify.client.PlaybackStateChanged
