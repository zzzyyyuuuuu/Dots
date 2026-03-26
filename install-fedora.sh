#!/bin/bash

echo "Updating system... Please wait, your PC is getting smarter."
sudo dnf update -y 
echo "Update done! Your CPU just finished its morning coffee."

echo "Hacking into the Matrix... Just Kidding. enabled Copr repos."
sudo dnf copr enable errornointernet/quickshell -y
sudo dnf copr enable solopasha/hyprland -y 
sudo dnf copr enable purian23/matugen -y 
echo "Success! Custom repos are now in the house."

echo "Checking for essential tools..."
for pkg in git fastfetch quickshell hyprland matugen; do
    if command -v $pkg &> /dev/null; then
        echo "-> $pkg is already installed. Skipping..."
    else
        echo "-> Installing $pkg..."
        sudo dnf install $pkg -y
    fi
done

echo "Vroom vroom! Cloning and setting your vroomies ..."
cd ~
rm -rf vroomies 
git clone --depth 1 https://github.com/maxchennn/vroomies.git 

cd vroomies 
mkdir -p ~/.config
mkdir -p ~/.local/share/fonts

cp -rf config/* ~/.config/
cp -rf fonts/* ~/.local/share/fonts/
fc-cache -f

cd ~
rm -rf vroomies

echo "------------------------------------------"
echo "Are you ready for the Alice Era? (y/n)"
read answer

if [ "$answer" == "y" ]; then
    echo "Correct! Even your CPU is dancing like Lady Gaga right now."
else
    echo "Error 404: Chill not found. Installing 'Bad Romance' instead..."
fi

echo "Done! Your configs are now in ~/.config"

