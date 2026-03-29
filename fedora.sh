#!/bin/bash

set -e

# progress bar function
progress_bar() {
    local duration=$1
    local steps=30
    local sleep_time=$(echo "$duration / $steps" | bc -l)

    for ((i=0; i<=steps; i++)); do
        percent=$((i * 100 / steps))
        bar=$(printf "%-${i}s" "#" )
        printf "\r[%-30s] %d%%" "$bar" "$percent"
        sleep $sleep_time
    done
    echo ""
}

clear
echo "Install vroomies for Fedora"
echo "------------------------------------------"

echo "Updating system..."
sudo dnf upgrade --refresh -y &>/dev/null &
progress_bar 3

echo "Enabling repos..."
sudo dnf copr enable -y errornointernet/quickshell &>/dev/null
sudo dnf copr enable -y solopasha/hyprland &>/dev/null
sudo dnf copr enable -y purian23/matugen &>/dev/null
progress_bar 2

echo "Installing packages..."
sudo dnf install -y git fastfetch quickshell hyprland matugen &>/dev/null &
progress_bar 4

echo "Cloning repos..."
mkdir -p ~/Pictures
[ ! -d ~/Pictures/Alice ] && git clone --depth 1 https://github.com/maxchennn/Alice.git ~/Pictures/Alice &>/dev/null

[ ! -d ~/vroomies ] && git clone --depth 1 https://github.com/maxchennn/vroomies.git ~/vroomies &>/dev/null
progress_bar 2

echo "Applying configs..."
mkdir -p ~/.config
rsync -a ~/vroomies/config/ ~/.config/ &>/dev/null

mkdir -p ~/.local/share/fonts
rsync -a ~/vroomies/fonts/ ~/.local/share/fonts/ &>/dev/null
fc-cache -fv &>/dev/null
progress_bar 2

echo "------------------------------------------"
echo "Are you ready for the Alice Era? (y/n)"
read answer

if [ "$answer" == "y" ]; then
    echo "Nice 😎"
else
    echo "Installing vibes..."
fi

echo "Done."
