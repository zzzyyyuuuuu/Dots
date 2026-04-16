#!/bin/bash

# ##################################################################
#            Lumina Fedora Installation Script (COPR)              #
# ##################################################################

# --- Package Definition ---
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
    'util-linux-user'

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
    'jetbrains-mono-fonts-all'
    'google-noto-sans-fonts'
    'google-noto-sans-cjk-fonts'
    'google-noto-emoji-fonts'
    'fontawesome-fonts'
    'powerline-fonts'
    'symbols-nerd-fonts'
    'cantarell-fonts'
)

# 1. Update and Enable COPR Repositories
echo "🔄 Updating system and enabling COPR repositories..."
sudo dnf update -y
sudo dnf copr enable -y solopasha/hyprland           # For Hyprland
sudo dnf copr enable -y errornointernet/quickshell  # For Quickshell
sudo dnf copr enable -y chelmi/zen-browser-bin      # For Zen Browser
sudo dnf copr enable -y sentry/matugen              # For Matugen

# 2. Package Installation
echo "📦 Installing minimalist package set..."
sudo dnf install -y "${packages[@]}"

# 3. Config Management
echo "⚙️  Setting up configuration files..."
if [ ! -d "$HOME/.config" ]; then
    echo "📂 Creating .config directory..."
    mkdir -p "$HOME/.config"
fi

if [ -d "$HOME/vroomies/config" ]; then
    echo "📂 Copying custom configs from vroomies..."
    cp -r "$HOME/vroomies/config/"* "$HOME/.config/"
else
    echo "⚠️  Warning: ~/vroomies/config not found."
fi

# 4. Font Management
echo "🔡 Setting up custom fonts..."
FONT_DIR="$HOME/.local/share/fonts"

if [ ! -d "$FONT_DIR" ]; then
    mkdir -p "$FONT_DIR"
fi

if [ -d "$HOME/vroomies/fonts" ]; then
    echo "📂 Copying local fonts to $FONT_DIR..."
    cp -r "$HOME/vroomies/fonts/"* "$FONT_DIR/"
    fc-cache -f
    echo "✅ Font cache updated."
else
    echo "⚠️  Warning: ~/vroomies/fonts not found."
fi

# 5. Shell Setup
echo "🐚 Changing default shell to Fish..."
if command -v fish &> /dev/null; then
    sudo chsh -s /usr/bin/fish $USER
    echo "✅ Shell successfully changed to Fish."
fi

echo ""
echo "✨ Fedora setup complete! Stay minimal, stay fast."
