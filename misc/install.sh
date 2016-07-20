#!/bin/bash

echo "Installing project-delta"

## Simple disk storage check. Naively assumes root partition holds all system data.
ROOT_AVAIL=$(df -k / | tail -n 1 | awk {'print $4'})
MIN_REQ="512000"

if [ $ROOT_AVAIL -lt $MIN_REQ ]; then
	echo "Insufficient disk space. Make sure you have at least 500MB available on the root partition."
	exit 1
fi

echo "Updating system package database..."
wget -qO - http://bintray.com/user/downloadSubjectPublicKey?username=bintray | sudo apt-key add -
echo "deb http://dl.bintray.com/kusti8/chromium-rpi jessie main" | sudo tee -a /etc/apt/sources.list
curl -sL https://deb.nodesource.com/setup_5.x | sudo bash -
sudo apt-get update

echo "Upgrading the system, this might take a while..."
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove

echo "Installing dependencies"
sudo apt-get -y install nano git binutils curl apt-utils build-essential unclutter chromium-browser nodejs
curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update && sudo chmod +x /usr/bin/rpi-update
sudo rpi-update

echo "Downloading project-delta"
git clone https://github.com/Ultimatum22/Project-Delta.git "$HOME/project-delta"

echo "Installing project-delta"
sudo npm install bower -g
cd ~/project-delta/app/static && bower install && cd ~/project-delta
sudo pip install -r requirements.txt

echo "Change system timezone and locale"
sudo dpkg-reconfigure locales tzdata

echo "Create 1GB swap file"
sudo dd if=/dev/zero of=/swap bs=1M count=1024 && sudo mkswap /swap
sudo sed -i '$a /swap none swap sw 0 0' /etc/fstab

echo "Change /boot/config.txt"
sudo sed -i 's/#hdmi_group=1/hdmi_group=1/g' /boot/config.txt
sudo sed -i 's/#hdmi_mode=1/hdmi_mode=16/g' /boot/config.txt

echo "Setup network connection for wireless"
sudo mv /etc/network/interfaces /etc/network/interfaces.bck
sudo cp "$HOME/project-delta/misc/network_interface" /etc/network/interfaces

echo "Setup chromium to autostart at boot"
cp /etc/xdg/lxsession/LXDE-pi/autostart /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i 's/@lxpanel --profile LXDE-pi/#@lxpanel --profile LXDE-pi/g' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i 's/@pcmanfm --desktop --profile LXDE-pi/#@pcmanfm --desktop --profile LXDE-pi/g' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i 's/@xscreensaver -no-splash/#@xscreensaver -no-splash/g' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @xset s off' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @xset -dpms' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @xset s noblank' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @unclutter -idle 0.1 -root' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @chromium-browser --incognito --kiosk http://localhost:4001' /home/pi/.config/lxsession/LXDE-pi/autostart

echo "Rebooting system"
sudo reboot