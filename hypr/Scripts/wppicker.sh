#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"
ROFI_CONFIG="$HOME/.config/rofi/config-wallpaper.rasi"

# Safety
cd "$WALLPAPER_DIR" || exit 1

# Pick a random wallpaper first (for preview icon)
RANDOM_WALL="$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
  \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) | shuf -n 1)"

# Build rofi menu
SELECTED_WALL=$(
  {
    printf "󰒺 Random Wallpaper\0icon\x1f%s\n" "$RANDOM_WALL"

    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
      \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) \
      -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2- |
    while read -r img; do
      name="$(basename "$img")"
      printf "%s\0icon\x1f%s\n" "$name" "$img"
    done
  } |
  rofi -dmenu -i -p "Wallpaper" -show-icons -config "$ROFI_CONFIG"
)

# Exit if nothing selected
[ -z "$SELECTED_WALL" ] && exit 0

# Resolve selected wallpaper path
if [[ "$SELECTED_WALL" == *Random* ]]; then
  SELECTED_PATH="$RANDOM_WALL"
else
  SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"
fi

# Apply colors
matugen image "$SELECTED_PATH"

# Update symlink
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

# Restart hyprpaper
pkill hyprpaper
sleep 0.2
hyprpaper &

# Restart swaync
pkill swaync
sleep 0.2
swaync &

# Restart waybar
pkill waybar
sleep 0.2
waybar &

