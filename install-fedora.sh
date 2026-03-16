#!/bin/bash
set -e

CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
NC='\033[0m'

clear
echo -e "${BLUE}●${NC} ${CYAN}Pure-Flow v1.1.0${NC} ${GRAY}-----------------------------------${NC}"
echo ""

PACKAGES=(hyprland hyprpaper hyprlock swaync matugen rofi waybar kitty dolphin wlogout)
total=${#PACKAGES[@]}
count=0

sudo dnf copr enable -y solopasha/hyprland > /dev/null 2>&1
sudo dnf copr enable -y purian23/matugen > /dev/null 2>&1

for pkg in "${PACKAGES[@]}"; do
    count=$((count + 1))
    percent=$((count * 100 / total))
    filled=$((percent / 5))
    empty=$((20 - filled))
    
    bar=$(printf "%${filled}s" | tr ' ' '━')
    spacer=$(printf "%${empty}s" | tr ' ' ' ')

    printf "\r${BLUE}  Deploying ${NC}%-15s ${BLUE}[${bar}${GRAY}${spacer}${BLUE}]${NC} %3d%%" "$pkg" "$percent"
    
    sudo dnf install -y "$pkg" > /dev/null 2>&1
done

echo -e "\n\n${GREEN}  ✔ Core components successfully deployed.${NC}"

if [ -d "fonts" ]; then
    echo -e "${BLUE}  ●${NC} Synchronizing fonts..."
    mkdir -p ~/.local/share/fonts
    cp -r fonts/*.{ttf,otf} ~/.local/share/fonts/ 2>/dev/null || cp -r fonts/* ~/.local/share/fonts/
    fc-cache -fv > /dev/null 2>&1
fi

mkdir -p ~/.config
[ -d ~/.config/hypr ] && mv ~/.config/hypr ~/.config/hypr_old_$(date +%Y%m%d_%H%M)
cp -r config/* ~/.config/
chmod +x ~/.config/hypr/scripts/* 2>/dev/null || true
sed -i "s|/home/$USER/|$HOME/|g" ~/.config/hypr/*.conf 2>/dev/null || true

echo -e "\n${CYAN}  Finished.${NC} ${GRAY}Pure-Flow is ready to use.${NC}"
