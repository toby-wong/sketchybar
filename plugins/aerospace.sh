#!/bin/bash
# Refreshes all AeroSpace workspace items (focus, monitor, app icons)
# and the layout indicator. Run by the `aerospace` item on any change.

export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

if [ "$1" = "toggle" ]; then
  first=$(aerospace list-workspaces --all | head -1)
  if [ "$(sketchybar --query space.$first | jq -r '.label.drawing')" = "on" ]; then
    state=off; chevron=􀆊
  else
    state=on; chevron=􀆉
  fi
  args=()
  for sid in $(aerospace list-workspaces --all); do
    args+=(--set space.$sid label.drawing=$state)
  done
  sketchybar "${args[@]}" --set separator icon=$chevron
  exit 0
fi

focused=$(aerospace list-workspaces --focused)
args=()

# Workspace items: highlight, which display, app icons
while read -r sid display; do
  [ -z "$sid" ] && continue
  icon_strip=" "
  apps=$(aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null \
         | grep -v '^zoom.us$' | awk '!seen[$0]++')
  while IFS= read -r app; do
    [ -n "$app" ] && icon_strip+=" $("$HOME/.config/sketchybar/plugins/icon_map.sh" "$app")"
  done <<< "$apps"

  if [ "$sid" = "$focused" ]; then hl=on; else hl=off; fi
  args+=(--set space.$sid icon.highlight=$hl display=$display label="$icon_strip")
done < <(aerospace list-workspaces --all --format '%{workspace} %{monitor-appkit-nsscreen-screens-id}')

# Layout indicator for the focused window
layout=$(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null)
case "$layout" in
  floating)    args+=(--set aerospace icon=$YABAI_FLOAT icon.color=$MAGENTA) ;;
  *accordion*) args+=(--set aerospace icon=$YABAI_STACK icon.color=$RED) ;;
  *)           args+=(--set aerospace icon=$YABAI_GRID  icon.color=$ORANGE) ;;
esac

sketchybar "${args[@]}"
