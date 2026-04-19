#!/bin/bash
# ##################################################################
#                 vroomies  Arch Installation Script               #
# ##################################################################

set -e

packages=(
    # --- Core & Terminal ---
    'git'
    'kitty'
    'neovim'
    'wget'
    'unzip'
    'fastfetch'
    'htop'
    'fish'
    'dolphin'
    # --- System Tools ---
    'pavucontrol'
    'gufw'
    'gnome-disk-utility'
    # --- Productivity & Media ---
    'keepassxc'
    'yt-dlp'
    'localsend'
    'discord'
    'mpv'
    'zen-browser-bin'
    'firefox'
    # --- Ricing (Pure-Flow Essentials) ---
    'hyprland'
    'swww'
    'matugen'
    'quickshell'
    # --- Fonts ---
    'ttf-jetbrains-mono-nerd'
    'cantarell-fonts'
    'noto-fonts'
    'noto-fonts-cjk'
    'noto-fonts-emoji'
    'awesome-terminal-fonts'
    'powerline-fonts'
    'ttf-nerd-fonts-symbols'
)

# 1. Check for yay
if ! command -v yay &> /dev/null; then
    echo "❌ Error: yay is not installed."
    exit 1
fi

# 2. System Update
echo "🔄 Synchronizing databases and updating system..."
yay -Syu --noconfirm

# 3. Package Installation
echo "📦 Installing minimalist package set..."
yay -S --needed --noconfirm "${packages[@]}"

# 4. Config Management
echo "⚙️  Setting up configuration files..."
mkdir -p "$HOME/.config"
if [ -d "$HOME/vroomies/config" ]; then
    echo "📂 Copying custom configs from vroomies..."
    cp -r "$HOME/vroomies/config/"* "$HOME/.config/"
else
    echo "⚠️  Warning: ~/vroomies/config directory not found."
fi

# 5. Font Management
echo "🔡 Setting up custom fonts..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [ -d "$HOME/vroomies/fonts" ]; then
    echo "📂 Copying fonts to $FONT_DIR..."
    cp -r "$HOME/vroomies/fonts/"* "$FONT_DIR/"
    fc-cache -f
    echo "✅ Font cache updated."
else
    echo "⚠️  Warning: ~/vroomies/fonts directory not found."
fi

# 6. Shell Setup
echo "🐚 Changing default shell to Fish..."
if command -v fish &> /dev/null; then
    chsh -s "$(which fish)"
    echo "✅ Shell successfully changed to Fish."
fi

echo ""
echo "✨ Setup complete! Stay minimal, stay fast."
