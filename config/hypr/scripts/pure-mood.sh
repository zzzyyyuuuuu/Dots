#!/bin/bash

MOOD_DIR="$HOME/.config/hypr/moods"
CURRENT_MOOD="$HOME/.config/hypr/current_mood.conf"
ROFI_THEME="$HOME/.config/rofi/pure-mood.rasi"

if [ ! -d "$MOOD_DIR" ]; then
    mkdir -p "$MOOD_DIR"
fi

SELECTED=$(ls "$MOOD_DIR" | grep '\.conf$' | sed 's/\.conf//g' | rofi -dmenu -theme "$ROFI_THEME" -p "Pure-Mood:")

if [ -n "$SELECTED" ]; then
    ln -sf "$MOOD_DIR/$SELECTED.conf" "$CURRENT_MOOD"
    hyprctl reload
    notify-send "Pure-Mood" "Sistem $SELECTED moduna geçti!" -i display
fi
