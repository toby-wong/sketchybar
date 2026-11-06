#!/bin/bash

# sketchybar invokes subscribed `script`s (and the boot `--update`) with a
# minimal PATH, so yabai/jq are not on it by default. Prepend Homebrew bin.
export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"

# Reactively expand/collapse the space app-icon labels on display change.
#
# Subscribed to the `display_change` event (and run once at boot via the
# `sketchybar --update` in sketchybarrc, plus an explicit call at the end of
# items/spaces.sh). When an external monitor is connected (>1 display) the
# per-space app-icon labels are revealed and the toggle chevron is set to its
# expanded glyph; on returning to a single display they are collapsed again.

YABAI_SPACES=$(yabai -m query --spaces | jq -r '.[].index' | sort -n)
DISPLAY_COUNT=$(yabai -m query --displays | jq 'length')

if [ "$DISPLAY_COUNT" -gt 1 ]; then
  state="on"
  chevron=􀆉   # expanded
else
  state="off"
  chevron=􀆊   # collapsed
fi

for space_index in $YABAI_SPACES; do
  sketchybar --set space.$space_index label.drawing=$state
done
sketchybar --set separator icon=$chevron
