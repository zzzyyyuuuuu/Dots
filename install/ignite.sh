#!/bin/bash
# ##################################################################
#            Lumina Fedora Installation Script (COPR)              #
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
    'util-linux-user'
    'dolphin'
    # --- System Tools ---
    'pavucontrol'
    'gufw'
    'gnome-disk-utility'
    # --- Productivity & Media ---
    'keepassxc'
    'yt-dlp'
    'mpv'
    'firefox'
    'discord'
    # --- Ricing (Pure-Flow Essentials) ---
    'hyprland'
    'swww'
    'matugen'
    'quickshell'
    'zen-browser'
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
 
# 1. RPM Fusion
echo "🔧 Enabling RPM Fusion repositories..."
sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
 
# 2. COPR Repositories
echo "📡 Enabling COPR repositories..."
sudo dnf copr enable -y solopasha/hyprland
sudo dnf copr enable -y errornointernet/quickshell
sudo dnf copr enable -y sentry/matugen
sudo dnf copr enable -y tchekrekjian/zen-browser
 
# 3. System Update
echo "🔄 Updating system..."
sudo dnf update -y
 
# 4. LocalSend — Flatpak
echo "📦 Installing LocalSend via Flatpak..."
flatpak install -y flathub org.localsend.LocalSend 2>/dev/null || \
  echo "⚠️  LocalSend kurulamadı, manuel kur."
 
# 5. Package Installation
echo "📦 Installing minimalist package set..."
sudo dnf install -y "${packages[@]}"
 
# 6. Config Management
echo "⚙️  Setting up configuration files..."
mkdir -p "$HOME/.config"
if [ -d "$HOME/vroomies/config" ]; then
    echo "📂 Copying custom configs from vroomies..."
    cp -r "$HOME/vroomies/config/"* "$HOME/.config/"
else
    echo "⚠️  Warning: ~/vroomies/config not found."
fi
 
# 7. Font Management
echo "🔡 Setting up custom fonts..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [ -d "$HOME/vroomies/fonts" ]; then
    echo "📂 Copying local fonts to $FONT_DIR..."
    cp -r "$HOME/vroomies/fonts/"* "$FONT_DIR/"
    fc-cache -f
    echo "✅ Font cache updated."
else
    echo "⚠️  Warning: ~/vroomies/fonts not found."
fi
 
# 8. Shell Setup
echo "🐚 Changing default shell to Fish..."
if command -v fish &> /dev/null; then
    sudo chsh -s /usr/bin/fish "$USER"
    echo "✅ Shell changed to Fish."
fi
 
echo ""
echo "✨ Fedora setup complete! Stay minimal, stay fast."
 
