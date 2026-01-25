#!/bin/bash

# openSUSE versiyonunu anla
. /etc/os-release

echo "------------------------------------------"
echo "🦎 openSUSE $NAME ($VERSION_ID) Tespit Edildi"
echo "------------------------------------------"

# 1. Ortak ve OPI kurulumu
sudo zypper install -y opi rsync swww jetbrainsmono-fonts

if [[ "$ID" == "opensuse-tumbleweed" ]]; then
    echo "🚀 Tumbleweed: En güncel paketler kuruluyor..."
    sudo zypper install -y hyprland waybar rofi-wayland
    opi matugen # Tumbleweed'de direkt bulur
    
elif [[ "$ID" == "opensuse-leap" ]]; then
    echo "🛡️  Leap: Stabil paketler ve gerekli depolar ekleniyor..."
    # Leap'te Hyprland bazen resmi depoda olmaz, OBS'den çekmek gerekir
    opi hyprland
    opi waybar
    opi matugen
    sudo zypper install -y rofi
fi

# 2. Yazı tipi önbelleğini tazele
fc-cache -fv

echo "✅ openSUSE ($VERSION_ID) kurulumu başarıyla tamamlandı!"
