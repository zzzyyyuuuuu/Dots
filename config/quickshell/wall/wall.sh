#!/usr/bin/env bash

SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"
SELECTED_PATH="${1:-}"

if [[ -z "$SELECTED_PATH" ]]; then
    pkill -f "quickshell.*wall.qml" || true
    QML_XHR_ALLOW_FILE_READ=1 quickshell --path "$HOME/.config/quickshell/wall/wall.qml" &
    exit 0
fi

[[ ! -f "$SELECTED_PATH" ]] && { echo "Dosya bulunamadı: $SELECTED_PATH" >&2; exit 1; }

ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

# if you use fedora / opensuse leap : delete awww , write swww
awww img "$SELECTED_PATH" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-duration 1.2 \
    --transition-fps 144 \
    --transition-bezier 0.22,1.2,0.36,1 \
    --resize crop

matugen image "$SELECTED_PATH" --source-color-index 0

pkill swaync 2>/dev/null || true
swaync &

pkill -9 quickshell || true
sleep 1
QML_XHR_ALLOW_FILE_READ=1 quickshell --path "$HOME/.config/quickshell/shell.qml" &
