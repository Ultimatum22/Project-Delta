#!/bin/sh
xset -dpms # disable DPMS (Energy Star) features.
xset s off # disable screen saver
xset s noblank # don't blank the video device
unclutter &
matchbox-window-manager &

#sleep 60
chromium-browser --kiosk http://localhost:4001
#while true; do
#  #midori -e Fullscreen -a http://dakboard.com/index.php?p=dae470011729c40f4408154f3898bda8
#  midori -e Fullscreen -a http://localhost:3000
#done;