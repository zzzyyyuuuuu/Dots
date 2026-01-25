#!/bin/bash

# 1. Sistemi Anla
. /etc/os-release

# 2. Uygun Scripti Dahil Et (Include)
if [ "$ID" == "fedora" ]; then
    source ./fedora.sh
elif [ "$ID" == "arch" ]; then
    source ./arch.sh
elif [ "$ID" == "opensuse-tumbleweed" ] || [ "$ID" == "opensuse" ]; then
    source ./opensuse.sh
else
    echo "Desteklenmeyen sistem!"
    exit 1
fi

# 3. Ortak İşleri Yap (Dosya kopyalama gibi)
mkdir -p ~/.config/hypr
cp -r hypr/* ~/.config/hypr/
echo "Kurulum tamamlandı aşkım!"
