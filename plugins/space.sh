#!/bin/bash

update() {
  WIDTH="dynamic"
  if [ "$SELECTED" = "true" ]; then
    WIDTH="0"
  fi

  sketchybar --animate tanh 20 --set $NAME icon.highlight=$SELECTED label.width=$WIDTH
  
  # Trigger windows_on_spaces to update app icons for all spaces
  sketchybar --trigger windows_on_spaces
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    yabai -m space --destroy $SID
    sketchybar --trigger space_change --trigger windows_on_spaces
  else
    # Map space numbers to their corresponding key codes
    case $SID in
      1) KEY_CODE=18 ;;   # Key '1'
      2) KEY_CODE=19 ;;   # Key '2'
      3) KEY_CODE=20 ;;   # Key '3'
      4) KEY_CODE=21 ;;   # Key '4'
      5) KEY_CODE=23 ;;   # Key '5'
      6) KEY_CODE=22 ;;   # Key '6'
      7) KEY_CODE=26 ;;   # Key '7'
      8) KEY_CODE=28 ;;   # Key '8'
      9) KEY_CODE=25 ;;   # Key '9'
      10) KEY_CODE=29 ;;  # Key '0'
      11) KEY_CODE=27 ;;  # Key '-' (minus)
      12) KEY_CODE=24 ;;  # Key '=' (equals)
      *) KEY_CODE=18 ;;   # Default to '1'
    esac
    
    # Send keyboard shortcut: lctrl + shift + {space number}
    osascript -e "tell application \"System Events\" to key code $KEY_CODE using {control down, shift down}"
    # Also focus the space as backup
    yabai -m space --focus $SID 2>/dev/null
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
