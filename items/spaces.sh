#!/bin/bash

# Get actual yabai spaces
YABAI_SPACES=$(yabai -m query --spaces | jq -r '.[].index' | sort -n)
SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15")

# Handle command line arguments first
case "$1" in
  "toggle")
    # Toggle spaces visibility - check if app icons are visible
    visible=$(sketchybar --query space.1 | jq -r '.label.drawing')
    
    if [ "$visible" = "on" ]; then
      # App icons are visible, hide everything (space numbers + app icons)
      for space_index in $YABAI_SPACES; do
        sketchybar --set space.$space_index icon.drawing=on label.drawing=off
      done
      # Set separator to collapsed state icon
      sketchybar --set separator icon=􀆊
    else
      # App icons are hidden, show everything (space numbers + app icons)
      for space_index in $YABAI_SPACES; do
        sketchybar --set space.$space_index icon.drawing=on label.drawing=on
      done
      # Set separator to expanded state icon
      sketchybar --set separator icon=􀆉
    fi
    exit 0
    ;;
esac

sid=0
spaces=()
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))

  space=(
    associated_space=$sid
    icon=${SPACE_ICONS[i]}
    icon.padding_left=6
    icon.padding_right=6
    padding_left=2
    padding_right=3
    label.padding_right=16
    icon.highlight_color=$RED
    label.font="sketchybar-app-font:Regular:13.0"
    label.background.height=18
    label.background.drawing=off
    label.background.color=$BACKGROUND_2
    label.background.corner_radius=6
    label.drawing=off
    icon.drawing=on
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

spaces=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  background.border_width=2
  background.drawing=on
  background.corner_radius=8
)

separator=(
  icon=􀆊
  icon.font="$FONT:Heavy:16.0"
  padding_left=15
  padding_right=10
  label.drawing=off
  # associated_display=active
  click_script="/Users/tobywo/.config/sketchybar/items/spaces.sh toggle"
  icon.color=$WHITE
)

sketchybar --add bracket spaces '/space\..*/' \
           --set spaces "${spaces[@]}"        \
                                              \
           --add item separator left          \
           --set separator "${separator[@]}"
