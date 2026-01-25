#!/bin/bash

echo "------------------------------------------"
echo "👑 Fedora: Solopasha + Satori Gücü Adına!"
echo "------------------------------------------"

# 1. Her İki COPR Deposunu da Aç
echo "🚀 Depolar etkinleştiriliyor..."
sudo dnf copr enable -y solopasha/hyprland   # Hyprland buranın kralı
sudo dnf copr enable -y mradityaalok/satori  # Matugen de buradan geliyor

# 2. Paketleri Kur
echo "📦 Her şey yükleniyor aşko..."
sudo dnf install -y \
    hyprland \
    matugen \
    waybar \
    rofi-wayland \
    swww \
    rsync \
    jetbrains-mono-fonts-all

echo "✅ Fedora tarafı artık yıkılıyor! Solopasha ve Satori hazır."
