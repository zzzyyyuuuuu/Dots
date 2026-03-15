#!/bin/bash
set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}🌌 Pure-Flow: Starting Arch Linux Installation...${NC}"

sudo pacman -S --needed --noconfirm base-devel git hyprland hyprpaper swaync rofi-wayland waybar kitty dolphin rust

if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
fi

yay -S --noconfirm matugen

mkdir -p ~/.config

if [ -d ~/.config/hypr ]; then
    mv ~/.config/hypr ~/.config/hypr_old_$(date +%Y%m%d)
fi

cp -r config/* ~/.config/
chmod +x ~/.config/hypr/scripts/* 2>/dev/null || true

sed -i "s|/home/$USER/|$HOME/|g" ~/.config/hypr/hyprpaper.conf 2>/dev/null || true
sed -i "s|/home/$USER/|$HOME/|g" ~/.config/hypr/hyprland.conf 2>/dev/null || true

echo -e "${GREEN}✨ Installation complete! Pure-Flow is ready on Arch.${NC}"
