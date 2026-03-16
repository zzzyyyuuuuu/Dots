#!/usr/bin/env bash
set -e

CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear
echo -e "${BLUE}[*]${NC} ${CYAN}Pure-Flow Arch Installer${NC} ${GRAY}-----------------------------------${NC}"

# sudo check
if ! sudo -v; then
    echo "Sudo permission required."
    exit 1
fi

# ensure lspci exists
if ! command -v lspci &> /dev/null; then
    echo -e "${YELLOW}[!] Installing pciutils...${NC}"
    sudo pacman -S --noconfirm pciutils
fi

GPU_TYPE=$(lspci | grep -iE 'vga|3d')

if echo "$GPU_TYPE" | grep -qi nvidia; then
    echo -e "${BLUE}[i]${NC} Nvidia GPU detected."
    sudo pacman -S --needed --noconfirm nvidia nvidia-utils libva-nvidia-driver
elif echo "$GPU_TYPE" | grep -qiE 'amd|ati'; then
    echo -e "${BLUE}[i]${NC} AMD GPU detected."
    sudo pacman -S --needed --noconfirm mesa xf86-video-amdgpu vulkan-radeon
else
    echo -e "${YELLOW}[!] Unknown GPU. Skipping driver install.${NC}"
fi

PACKAGES=(
base-devel
git
hyprland
hyprpaper
hyprlock
swaync
rofi-wayland
waybar
kitty
dolphin
matugen
wlogout
xdg-desktop-portal-hyprland
grim
slurp
wl-clipboard
aquamarine
)

echo -e "\n${BLUE}[*] Installing packages...${NC}"

for pkg in "${PACKAGES[@]}"; do
    printf "${GRAY}Installing %-25s${NC}\r" "$pkg"
    sudo pacman -S --needed --noconfirm "$pkg" >/dev/null 2>&1
done

echo -e "\n${GREEN}[+] Packages installed.${NC}"

# CONFIG INSTALL
echo -e "${BLUE}[*] Installing configs...${NC}"

CONFIG_DIR="$HOME/.config"

mkdir -p "$CONFIG_DIR"

if [ -d "config" ]; then
    cp -r config/* "$CONFIG_DIR/"
    echo -e "${GREEN}[+] Config files copied.${NC}"
else
    echo -e "${YELLOW}[!] config folder not found. Skipping.${NC}"
fi

# FONT INSTALL
echo -e "${BLUE}[*] Installing fonts...${NC}"

FONT_DIR="$HOME/.local/share/fonts"

if [ ! -d "$FONT_DIR" ]; then
    mkdir -p "$FONT_DIR"
    echo -e "${GRAY}[i] Created font directory.${NC}"
fi

if [ -d "fonts" ]; then
    find fonts -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONT_DIR/" \;
    fc-cache -fv >/dev/null 2>&1
    echo -e "${GREEN}[+] Fonts installed.${NC}"
else
    echo -e "${YELLOW}[!] fonts folder not found. Skipping.${NC}"
fi

# SCRIPT PERMISSIONS
chmod +x "$HOME/.config/hypr/scripts/"* 2>/dev/null || true

echo -e "\n${CYAN}Finished.${NC} ${GRAY}Pure-Flow is ready :)${NC}"
