#!/usr/bin/env bash
set -e

WALL_DIR="$HOME/Pictures/"

if [ ! -d "$WALL_DIR" ]; then
    git clone https://github.com/maxuwuu/pure-walls.git "$WALL_DIR"
else
    cd "$WALL_DIR" && git pull
fi
