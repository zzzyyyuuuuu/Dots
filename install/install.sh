#!/bin/bash

# ##################################################################
#                 Minimalist Arch Installation Script               #
# ##################################################################

packages=(
    'git' 'kitty' 'neovim' 'wget' 'unzip' 'fastfetch' 'htop' 'fish'
    'pavucontrol' 'gufw' 'gnome-disk-utility'
    'keepassxc' 'yt-dlp' 'localsend' 'discord' 'mpv'
    'zen-browser-bin' 'firefox'
    'ttf-jetbrains-mono-nerd' 'cantarell-fonts' 'noto-fonts' 
    'noto-fonts-cjk' 'awesome-terminal-fonts' 'powerline-fonts'
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
yay -S --needed "${packages[@]}"

# 4. Config Management
echo "⚙️  Setting up configuration files..."
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"

if [ -d "$HOME/vroomies/config" ]; then
    echo "📂 Copying custom configs from vroomies..."
    cp -r "$HOME/vroomies/config/"* "$HOME/.config/"
else
    echo "⚠️  Warning: ~/vroomies/config directory not found."
fi

# 5. Font Management (Custom Fonts Folder)
echo "🔡 Setting up custom fonts..."
FONT_DIR="$HOME/.local/share/fonts"

[ ! -d "$FONT_DIR" ] && mkdir -p "$FONT_DIR"

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
    chsh -s $(which fish)
    echo "✅ Shell successfully changed to Fish."
fi

echo ""
echo "✨ Setup complete! Stay minimal, stay fast."
