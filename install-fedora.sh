#!/usr/bin/env bash
set -e

CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear
echo -e "${BLUE}[*]${NC} ${CYAN}Pure-Flow Fedora Installer${NC} ${GRAY}-----------------------------------${NC}"

# sudo check
if ! sudo -v; then
    echo "Sudo permission required."
    exit 1
fi

# ensure lspci exists
if ! command -v lspci &> /dev/null; then
    echo -e "${YELLOW}[!] Installing pciutils...${NC}"
    sudo dnf install -y pciutils
fi

GPU_TYPE=$(lspci | grep -iE 'vga|3d')

if echo "$GPU_TYPE" | grep -qi nvidia; then
    echo -e "${BLUE}[i]${NC} Nvidia GPU detected."
    if ! rpm -q akmod-nvidia >/dev/null; then
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    else
        echo -e "${GREEN}[+] Nvidia drivers already installed.${NC}"
    fi
elif echo "$GPU_TYPE" | grep -qiE 'amd|ati'; then
    echo -e "${BLUE}[i]${NC} AMD GPU detected."
    if ! rpm -q mesa-dri-drivers >/dev/null; then
        sudo dnf install -y mesa-dri-drivers mesa-vulkan-drivers
    else
        echo -e "${GREEN}[+] AMD drivers already installed.${NC}"
    fi
else
    echo -e "${YELLOW}[!] Unknown GPU. Skipping driver install.${NC}"
fi

# enable repos
sudo dnf copr enable -y solopasha/hyprland >/dev/null 2>&1
sudo dnf copr enable -y purian23/matugen >/dev/null 2>&1

PACKAGES=(
hyprland
hyprpaper
hyprlock
swaync
rofi
waybar
kitty
dolphin
matugen
wlogout
xdg-desktop-portal-hyprland
grim
slurp
wl-clipboard
)

echo -e "\n${BLUE}[*] Installing packages...${NC}"

for pkg in "${PACKAGES[@]}"; do
    printf "${GRAY}Installing %-25s${NC}\r" "$pkg"
    sudo dnf install -y "$pkg" >/dev/null 2>&1
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

# WALLPAPER SETUP
if [ -f "./wallpapers.sh" ]; then
    source ./wallpapers.sh
fi

echo -e "\n${CYAN}Finished.${NC} ${GRAY}Pure-Flow is ready :)${NC}"
