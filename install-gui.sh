#!usr/bin/bash

sudo mv start-xfce4 /usr/bin
sudo mv xfce4.service /etc/systemd/system

sudo systemctl enable xfce4.service
echo "gui installed! reboot to start desktop!"
echo "run install-turnip.sh to get gui acceleration on ADRENO gpus"