#!/bin/bash
set -e

CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear
echo -e "${BLUE}[*]${NC} ${CYAN}Pure-Flow v1.1.0${NC} ${GRAY}-----------------------------------${NC}"

GPU_TYPE=$(lspci | grep -iE 'vga|3d')

if echo "$GPU_TYPE" | grep -qi nvidia; then
    echo -e "${BLUE}[i]${NC} Nvidia GPU detected."
    if ! pacman -Qs nvidia > /dev/null; then
        echo -e "${YELLOW}[!] Drivers not found. Installing nvidia-utils...${NC}"
        sudo pacman -S --noconfirm nvidia-utils libva-nvidia-driver
    else
        echo -e "${GREEN}[+] Nvidia drivers are already installed.${NC}"
    fi
elif echo "$GPU_TYPE" | grep -qiE 'amd|ati'; then
    echo -e "${BLUE}[i]${NC} AMD GPU detected."
    if ! pacman -Qs xf86-video-amdgpu > /dev/null; then
        echo -e "${YELLOW}[!] Drivers not found. Installing mesa drivers...${NC}"
        sudo pacman -S --noconfirm mesa xf86-video-amdgpu vulkan-radeon
    else
        echo -e "${GREEN}[+] AMD drivers are already installed.${NC}"
    fi
fi

PACKAGES=(base-devel git hyprland hyprpaper hyprlock swaync rofi-wayland waybar kitty dolphin matugen wlogout)
total=${#PACKAGES[@]}
count=0

for pkg in "${PACKAGES[@]}"; do
    count=$((count + 1))
    percent=$((count * 100 / total))
    filled=$((percent / 5))
    empty=$((20 - filled))
    bar=$(printf "%${filled}s" | tr ' ' '=')
    spacer=$(printf "%${empty}s" | tr ' ' '-')

    printf "\r${BLUE} Deploying ${NC}%-15s ${BLUE}[${bar}${GRAY}${spacer}${BLUE}]${NC} %3d%%" "$pkg" "$percent"
    sudo pacman -S --needed --noconfirm "$pkg" > /dev/null 2>&1
done

echo -e "\n\n${GREEN}[+] Core components successfully deployed.${NC}"

if [ -d "fonts" ]; then
    echo -e "${BLUE}[*]${NC} Synchronizing fonts..."
    mkdir -p ~/.local/share/fonts/pure-fonts
    find fonts -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} ~/.local/share/fonts/pure-fonts/ \;
    fc-cache -fv > /dev/null 2>&1
fi

mkdir -p ~/.config
[ -d ~/.config/hypr ] && mv ~/.config/hypr ~/.config/hypr_old_$(date +%Y%m%d_%H%M)
cp -r config/* ~/.config/
chmod +x ~/.config/hypr/scripts/* 2>/dev/null || true
sed -i "s|/home/$USER/|$HOME/|g" ~/.config/hypr/*.conf 2>/dev/null || true

echo -e "\n${CYAN}Finished.${NC} ${GRAY}Pure-Flow is ready to use :)${NC}"
