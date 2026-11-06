#!/bin/bash

acme=(
  script="$PLUGIN_DIR/acme.sh"
  icon.font="$FONT:Bold:16.0"
  icon=􀒳
  padding_right=0
  padding_left=0
  label.drawing=on
  update_freq=3600
  updates=on
)

sketchybar --add item acme right        \
           --set acme "${acme[@]}"      \
           --subscribe acme system_woke
