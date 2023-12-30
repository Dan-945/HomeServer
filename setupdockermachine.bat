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

#list what packages to install from package manager
dev_packages=(
    'zsh'
    'vim'    
)

#Function to check if package already installed and if not install it.
install_dev(){
  for package in "${dev_packages[@]}"
  do
    echo "Installing $package"
    if ! command -v  $package &>/dev/null; then
     # install_$package
        sudo apt update && sudo apt upgrade
        sudo apt install $package
  echo "$package installed"
    else

     echo  "$package already installed"
    fi
  done
}

#run function for installing packages
install_dev


echo "mounting network shares"
 if [ -d "/mnt/docker_configs" ]
  then
          echo "Folder already exists, will not create"
  else
          echo "does not exist will create"
          mkdir "/mnt/docker_configs"
  fi

if [ $(grep "//192.168.1.198/configs/ /mnt/docker_configs" -c /etc/fstab) -ge 1 ]
then 
echo "its already there"
else 
 cat >> /etc/fstab << EOL
//192.168.1.198/configs/ /mnt/docker_configs/ cifs username=dm,password=linux,rw,iocharset=utf8,file_mode=0777
//192.168.1.161/Downloads/ /mnt/Downloads/ cifs username=dm,password=linux,rw,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm
//192.168.1.161/Pool4Configs/ /mnt/Pool4Configs/ cifs username=dm,password=linux,rw,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm
//192.168.1.161/Pool1Media/ /mnt/Pool1Media/ cifs username=dm,password=linux,rw,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm

//192.168.1.161/Pool2Media/ /mnt/Pool2Media/ cifs username=dm,password=linux,rw,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm

>
EOL
echo "its missing"
fi

mount -a

