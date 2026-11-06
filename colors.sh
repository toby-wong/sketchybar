#!/bin/bash

# Color Palette
export BLACK=0xff2e2c23
export WHITE=0xfffdf6f5
export RED=0xfff5c1be
export GREEN=0xffcafdc4
export BLUE=0xffbebdfa
export YELLOW=0xfff9e1c1
# ORANGE was previously byte-identical to RED (0xfff5c1be), which silently
# collapsed every 4-band escalation scale in the bar (memory, cpu, brew,
# battery) into 3 indistinguishable states. Re-derived in OKLCH to sit inside
# this theme's existing accent envelope: L=0.819 (matches BLUE 0.820),
# C=0.091 (matches GREEN 0.092, the most saturated accent), hue 59.5 between
# RED 22.2 and YELLOW 75.0. dE 0.0675 from RED and 0.1117 from YELLOW, both
# above the palette's own pre-existing minimum separation (RED/MAGENTA 0.0408).
export ORANGE=0xfff0b688
export MAGENTA=0xfff4bfda
export GREY=0xff2e2c23
export TRANSPARENT=0x00000000

# General bar colors
export BAR_COLOR=0xa0212121
export ICON_COLOR=$WHITE # Color of all icons
export LABEL_COLOR=$WHITE # Color of all labels
export BACKGROUND_1=0x90212121
export BACKGROUND_2=0x90e7d0ce

export POPUP_BACKGROUND_COLOR=0xff212121
export POPUP_BORDER_COLOR=$WHITE

export SHADOW_COLOR=$BLACK
