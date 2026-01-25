#!/bin/bash

echo "------------------------------------------"
echo "🦅 Arch Linux Otomatik Kurulum ve Paketler"
echo "------------------------------------------"

# 1. AUR Yardımcısı Seçimi ve Kurulumu
if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    echo "🤔 Sistemde AUR yardımcısı yok. Senin için kuralım gız!"
    echo "1) yay (En popüler, herkes bunu kullanır)"
    echo "2) paru (Rust ile yazılmış, havalı ve modern)"
    read -p "Seçimin nedir aşko? (1/2): " choice

    sudo pacman -S --needed base-devel git -y

    if [ "$choice" == "1" ]; then
        echo "📦 yay derleniyor, bekle biraz..."
        git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
        HELPER="yay"
    else
        echo "📦 paru derleniyor, Rust gücü adına!"
        git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd .. && rm -rf paru
        HELPER="paru"
    fi
else
    HELPER=$(command -v yay || command -v paru)
    echo "✅ Zaten $HELPER varmış, direkt paketlere geçiyorum!"
fi

# 2. Asıl Bomba: Paketlerin Kurulumu
echo "🚀 Şimdi asıl meseleye geldik: Hyprland ve tayfası kuruluyor..."

$HELPER -S --noconfirm --needed \
    hyprland \
    matugen-bin \
    waybar-hyprland \
    rofi-wayland \
    swww \
    rsync \
    ttf-jetbrains-mono-nerd \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \ 
    fastfetch

echo "✨ Arch tarafı çiçek gibi oldu, her şey hazır!"
