#!/bin/bash

memory_top=(
  label.font="$FONT:Semibold:7"
  label=MEM
  icon.drawing=off
  width=0
  padding_right=15
  y_offset=6
)

memory_percent=(
  label.font="$FONT:Heavy:12"
  label=MEM
  y_offset=-4
  padding_right=0
  width=55
  icon.drawing=off
  update_freq=2
  mach_helper="$HELPER"
)

memory_wired=(
  width=0
  graph.color=$MAGENTA
  graph.fill_color=$MAGENTA
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

memory_app=(
  graph.color=$GREEN
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

sketchybar --add item memory.top right                \
           --set memory.top "${memory_top[@]}"        \
                                                      \
           --add item memory.percent right            \
           --set memory.percent "${memory_percent[@]}" \
                                                      \
           --add graph memory.wired right 75          \
           --set memory.wired "${memory_wired[@]}"    \
                                                      \
           --add graph memory.app right 75            \
           --set memory.app "${memory_app[@]}"
