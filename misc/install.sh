#!/bin/bash

PROJECT_DIRECTORY="/home/pi/project-delta"

function delay() {
    sleep 0.2;
}

CURRENT_PROGRESS=0
function progress() {
    PARAM_PROGRESS=$1;
    PARAM_STATUS=$2;

    if [ ${CURRENT_PROGRESS} -le 0 -a ${PARAM_PROGRESS} -ge 0 ] ; then echo -ne "[..........................] (0%)  ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 5 -a ${PARAM_PROGRESS} -ge 5 ] ; then echo -ne "[#.........................] (5%)  ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 10 -a ${PARAM_PROGRESS} -ge 10 ]; then echo -ne "[##........................] (10%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 15 -a ${PARAM_PROGRESS} -ge 15 ]; then echo -ne "[###.......................] (15%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 20 -a ${PARAM_PROGRESS} -ge 20 ]; then echo -ne "[####......................] (20%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 25 -a ${PARAM_PROGRESS} -ge 25 ]; then echo -ne "[#####.....................] (25%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 30 -a ${PARAM_PROGRESS} -ge 30 ]; then echo -ne "[######....................] (30%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 35 -a ${PARAM_PROGRESS} -ge 35 ]; then echo -ne "[#######...................] (35%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 40 -a ${PARAM_PROGRESS} -ge 40 ]; then echo -ne "[########..................] (40%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 45 -a ${PARAM_PROGRESS} -ge 45 ]; then echo -ne "[#########.................] (45%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 50 -a ${PARAM_PROGRESS} -ge 50 ]; then echo -ne "[##########................] (50%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 55 -a ${PARAM_PROGRESS} -ge 55 ]; then echo -ne "[###########...............] (55%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 60 -a ${PARAM_PROGRESS} -ge 60 ]; then echo -ne "[############..............] (60%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 65 -a ${PARAM_PROGRESS} -ge 65 ]; then echo -ne "[#############.............] (65%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 70 -a ${PARAM_PROGRESS} -ge 70 ]; then echo -ne "[###############...........] (70%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 75 -a ${PARAM_PROGRESS} -ge 75 ]; then echo -ne "[#################.........] (75%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 80 -a ${PARAM_PROGRESS} -ge 80 ]; then echo -ne "[####################......] (80%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 85 -a ${PARAM_PROGRESS} -ge 85 ]; then echo -ne "[#######################...] (90%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 90 -a ${PARAM_PROGRESS} -ge 90 ]; then echo -ne "[##########################] (100%) ${PARAM_STATUS} \r" ; delay; fi;
    if [ ${CURRENT_PROGRESS} -le 100 -a ${PARAM_PROGRESS} -ge 100 ];then echo -ne 'Done!                                            \n' ; delay; fi;

    CURRENT_PROGRESS=${PARAM_PROGRESS};
}

echo "Installing project-delta"

progress 10 "Setting timezone and date"
sudo dpkg-reconfigure locales tzdata

progress 20 "Updating file system"
sudo apt-get update >&-
sudo apt-get -y dist-upgrade > /dev/null
sudo apt-get -y autoremove > /dev/null
sudo rpi-update > /dev/null

progress 30 "Installing dependencies"
wget -qO - http://bintray.com/user/downloadSubjectPublicKey?username=bintray | sudo apt-key add - > /dev/null
echo "deb http://dl.bintray.com/kusti8/chromium-rpi jessie main" | sudo tee -a /etc/apt/sources.list > /dev/null

curl -sL https://deb.nodesource.com/setup_6.x | sudo bash - > /dev/null
sudo apt-get -y install nano git binutils curl apt-utils build-essential unclutter chromium-browser nodejs samba samba-common-bin >&-
sudo npm install bower -g > /dev/null

progress 40 "Installing project-delta"
git clone https://github.com/Ultimatum22/Project-Delta.git ${PROJECT_DIRECTORY} --quiet
cd ${PROJECT_DIRECTORY}/app/static
bower install > /dev/null
cd ${PROJECT_DIRECTORY}
sudo pip install -r requirements.txt > /dev/null

progress 50 "Do configuration"
# Create 1GB swap file
sudo dd if=/dev/zero of=/swap bs=1M count=1024 && sudo mkswap /swap > /dev/null
sudo sed -i '$a /swap none swap sw 0 0' /etc/fstab > /dev/null

# Change /boot/config.txt
sudo sed -i 's/#hdmi_group=1/hdmi_group=1/g' /boot/config.txt >&-
sudo sed -i 's/#hdmi_mode=1/hdmi_mode=16/g' /boot/config.txt >&-

# Setup network connection for wireless
sudo mv /etc/network/interfaces /etc/network/interfaces.bck
sudo cp ${PROJECT_DIRECTORY}/misc/network_interface /etc/network/interfaces

sudo cp /etc/samba/smb.conf /etc/samba/smb.conf-bck
sudo sed -i 's/#   wins support = no/wins support = yes/g' /etc/samba/smb.conf

# Setup chromium to autostart at boot"
cp /etc/xdg/lxsession/LXDE-pi/autostart /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i 's/@lxpanel --profile LXDE-pi/#@lxpanel --profile LXDE-pi/g' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i 's/@pcmanfm --desktop --profile LXDE-pi/#@pcmanfm --desktop --profile LXDE-pi/g' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i 's/@xscreensaver -no-splash/#@xscreensaver -no-splash/g' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @xset s off' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @xset -dpms' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @xset s noblank' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @unclutter -idle 0.1 -root' /home/pi/.config/lxsession/LXDE-pi/autostart
sudo sed -i '$a @chromium-browser --incognito --kiosk http://localhost:4002' /home/pi/.config/lxsession/LXDE-pi/autostart

mkdir -p ${PROJECT_DIRECTORY}/app/static/photo_albums

echo '[Project-Delta photo albums]' >> /etc/samba/smb.conf
sudo sed -i '[Project-Delta photo albums]' /etc/samba/smb.conf
sudo sed -i ' comment=project-delta photo albums' /etc/samba/smb.conf
sudo sed -i ' path=${PROJECT_DIRECTORY}/app/static/photo_albums' /etc/samba/smb.conf
sudo sed -i ' browseable=Yes' /etc/samba/smb.conf
sudo sed -i ' writeable=Yes' /etc/samba/smb.conf
sudo sed -i ' only guest=no' /etc/samba/smb.conf
sudo sed -i ' create mask=0777' /etc/samba/smb.conf
sudo sed -i ' directory mask=0777' /etc/samba/smb.conf
sudo sed -i ' public=no' /etc/samba/smb.conf

progress 60 "Processing..."

progress 90 "Processing..."

progress 100 "Install complete, please reboot"

echo