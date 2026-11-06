#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

# Get ACME compliance status
COMPLIANCE_OUTPUT=$(/usr/local/bin/acme --compliance-status 2>/dev/null)

if [ $? -ne 0 ]; then
  # If ACME command fails, show error state
  sketchybar --set $NAME icon="󰀧" icon.color=$RED label="ACME Error" label.color=$RED
  exit 0
fi

# Parse compliance status
COMPLIANCE_STATUS=$(echo "$COMPLIANCE_OUTPUT" | grep "Compliance Status:" | awk -F': +' '{print $2}')
STATUS=$(echo "$COMPLIANCE_OUTPUT" | grep "^Status:" | awk -F': +' '{print $2}')

# Default values
ICON="􀒳"
COLOR=$YELLOW
LABEL=""

# Determine icon and color based on compliance status
if [[ "$COMPLIANCE_STATUS" == *"Compliant"* && "$COMPLIANCE_STATUS" != *"Noncompliant"* ]]; then
  # Fully compliant
  ICON="􀆅"
  COLOR=$GREEN
  # LABEL="Compliant"
elif [[ "$COMPLIANCE_STATUS" == *"Ingracetime"* ]]; then
  # In grace time - warning state
  ICON="􀇿"
  COLOR=$YELLOW
  LABEL="Grace Period"
elif [[ "$COMPLIANCE_STATUS" == *"Noncompliant"* ]]; then
  # Non-compliant - error state
  ICON="􀆄"
  COLOR=$RED
  LABEL="Non-compliant"
else
  # Unknown state
  ICON="􀒳"
  COLOR=$WHITE
  LABEL="Unknown"
fi

# Check if there's a deadline and show it in the label if within 7 days
DEADLINE=$(echo "$COMPLIANCE_OUTPUT" | grep "Deadline:" | awk -F': +' '{print $2}')
if [ ! -z "$DEADLINE" ]; then
  # Convert deadline to timestamp and get current time
  DEADLINE_TS=$(date -j -f "%Y-%m-%d %H:%M:%S" "$DEADLINE" "+%s" 2>/dev/null)
  CURRENT_TS=$(date "+%s")
  
  if [ ! -z "$DEADLINE_TS" ]; then
    DAYS_REMAINING=$(( (DEADLINE_TS - CURRENT_TS) / 86400 ))
    
    if [ $DAYS_REMAINING -le 7 ] && [ $DAYS_REMAINING -ge 0 ]; then
      if [ $DAYS_REMAINING -eq 0 ]; then
        LABEL="$LABEL (Today!)"
        COLOR=$RED
      elif [ $DAYS_REMAINING -eq 1 ]; then
        LABEL="$LABEL (1 day)"
        COLOR=$RED
      else
        LABEL="$LABEL (${DAYS_REMAINING}d)"
        if [ $DAYS_REMAINING -le 3 ]; then
          COLOR=$RED
        fi
      fi
    fi
  fi
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label="$LABEL" label.color=$COLOR
