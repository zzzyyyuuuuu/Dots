#!/usr/bin/env bash
set -euo pipefail

# ==========================
# CONFIG
# ==========================
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "webp")

# ==========================
# FUNCTIONS
# ==========================
is_image() {
    local f="$1"
    for ext in "${IMAGE_EXTENSIONS[@]}"; do
        [[ "${f,,}" == *.$ext ]] && return 0
    done
    return 1
}

pick_random_wallpaper() {
    find "$WALLPAPER_DIR" -maxdepth 1 -type f | grep -Ei '\.(jpg|jpeg|png|gif|webp)$' | shuf -n 1
}

reload_service() {
    case "$1" in
        hyprpaper)
            pkill hyprpaper 2>/dev/null || true
            sleep 0.2
            hyprpaper &
            ;;
        swaync)
            pkill swaync 2>/dev/null || true
            sleep 0.2
            swaync 2>/dev/null &
            ;;
        waybar)
            killall -USR1 waybar 2>/dev/null || true
            ;;
    esac
}

# ==========================
# SAFETY CHECK
# ==========================
cd "$WALLPAPER_DIR" || exit 1

# ==========================
# RANDOM PREVIEW
# ==========================
RANDOM_WALL="$(pick_random_wallpaper || true)"

# ==========================
# BUILD ROFI MENU (THUMBNAILS)
# ==========================
SELECTED_WALL="$(
{
    [[ -n "${RANDOM_WALL:-}" ]] && \
        printf "󰒺 Random Wallpaper\0icon\x1f%s\n" "$RANDOM_WALL"

    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        | grep -Ei '\.(jpg|jpeg|png|gif|webp)$' \
        | sort -r \
        | while read -r img; do
            printf "%s\0icon\x1f%s\n" "$(basename "$img")" "$img"
          done
} | rofi -dmenu -i -show-icons -config "$ROFI_CONFIG"
)"

# ==========================
# EXIT IF CANCELLED
# ==========================
[[ -z "$SELECTED_WALL" ]] && exit 0

# ==========================
# RESOLVE WALLPAPER PATH
# ==========================
if [[ "$SELECTED_WALL" == *Random* ]]; then
    SELECTED_PATH="$RANDOM_WALL"
else
    SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"
fi

# ==========================
# APPLY WALLPAPER (MATUGEN + HYPERPAPER)
# ==========================
# --source-color-index 0 ile renk promptunu atlıyoruz
matugen image "$SELECTED_PATH" --source-color-index 0

mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

# ==========================
# RELOAD COMPONENTS
# ==========================
reload_service hyprpaper
reload_service swaync || true
pkill waybar && waybar &
