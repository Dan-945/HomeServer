#!/bin/bash

if [ -d "/home/dm/configs" ]
then
        echo "Folder already exists, will not create"
else
        echo "does not exist will create"
        mkdir "/home/dm/configs"
fi

if ! hash samba 2>/dev/null; then
     # install_$package
        sudo apt update && sudo apt upgrade
        sudo apt install samba
        echo "$package installed"
    else

      echo "samba already installed"
    fi
echo "checking if samba share is setup"
if [ $(grep "configs" -c /etc/samba/smb.conf) -ge 10 ]
then
        echo "config is in place"
else
echo "adding config"
cat >> /etc/samba/smb.conf << EOL
[configs]
comment = Docker configs sharing
path = /home/dm/configs
force create mode = 0666
force directory mode = 0777
writable = yes
browseable = yes
public = yes
guest only = yes
EOL
sudo smbpasswd -a dm
sudo service smbd restart

fi
