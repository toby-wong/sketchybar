#!/bin/bash
# AeroSpace replacement for items/spaces.sh + items/front_app.sh.
# Loaded by sketchybarrc when AeroSpace is running (see wm-switch).

export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"

WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)
[ -z "$WORKSPACES" ] && WORKSPACES=$(seq 1 7)

sketchybar --add event aerospace_workspace_change \
           --add event aerospace_focus_change

for sid in $WORKSPACES; do
  space=(
    icon="$sid"
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
    label.drawing=on
    icon.drawing=on
    click_script="aerospace workspace $sid"
  )
  sketchybar --add item space.$sid left \
             --set space.$sid "${space[@]}"
done

spaces=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  background.border_width=2
  background.drawing=on
  background.corner_radius=8
)

separator=(
  icon=􀆉
  icon.font="$FONT:Heavy:16.0"
  padding_left=15
  padding_right=10
  label.drawing=off
  click_script="$PLUGIN_DIR/aerospace.sh toggle"
  icon.color=$WHITE
)

# Same role as the yabai item: shows the focused window's layout, click toggles float.
mode=(
  script="$PLUGIN_DIR/aerospace.sh"
  click_script="aerospace layout floating tiling; $PLUGIN_DIR/aerospace.sh"
  icon.font="$FONT:Regular:16.0"
  label.drawing=off
  icon.width=30
  icon=$YABAI_GRID
  icon.color=$ORANGE
  associated_display=active
)

front_app=(
  script='sketchybar --set $NAME label="$INFO"'
  icon.drawing=off
  padding_left=0
  label.color=$WHITE
  label.font="$FONT:Black:12.0"
  associated_display=active
)

sketchybar --add bracket spaces '/space\..*/'           \
           --set spaces "${spaces[@]}"                  \
           --add item separator left                    \
           --set separator "${separator[@]}"            \
           --add item aerospace left                    \
           --set aerospace "${mode[@]}"                 \
           --subscribe aerospace aerospace_workspace_change \
                                 aerospace_focus_change \
                                 front_app_switched     \
                                 space_windows_change   \
                                 display_change         \
           --add item front_app left                    \
           --set front_app "${front_app[@]}"            \
           --subscribe front_app front_app_switched
