#!/bin/bash

hyprctl dispatch togglefloating
hyprctl dispatch resizeactive exact 65% 75%
#sleep 0.1
hyprctl dispatch centerwindow

