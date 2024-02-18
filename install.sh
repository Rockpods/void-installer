#!/bin/bash

# TO-DO: Start work on KDE(and install OctoXBPS if using the KDE install) and Enlightenment.

echo "This script is not endorsed by the Void Linux project. If you have any issues, please report them at https://github.com/Rockpods/void-de-installer/."
echo "This has only been tested by installing from the the 2023-06-28 glibc live image with void-installer on the LCD Steam Deck and an HP Intel laptop. Please be more verbose if reporting issues using a different version of Void."
echo "You will have to reconfigure your WiFi once boot into GNOME."
echo "If you are running this script, you should already have an internet connection and already have Void Linux installed."
echo "IMPORTANT: IF YOU ARE USING AN NVIDIA GPU, DO NOT CONTINUE UNTIL YOU KNOW THAT THE GRAPHICS DRIVERS BEING INSTALLED ARE THE CORRECT ONES FOR YOUR CARD."
read -p "Do you want to continue with the installation?(yes/no) " gpu
if [[ "${gpu,,}" == *"no"* ]];then
   echo "exiting installer"
   exit
fi

# Update XBPS and Void packages to continue installation if someone installed from an old ISO without downloading packages from the internet, and enable extra repositories you will probably want to use at some point.
xbps-install -u xbps
xbps-install -Syu
xbps-install -y void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree

# Install graphics drivers and firmware/microcode
xbps-install -y intel-ucode linux-firmware-amd
read -p "What GPU are you using(AMD, Intel, or NVIDIA): " gpu
if [[ "${gpu,,}" == *"amd"* ]]; then
    echo "Installing graphics drivers for an AMD GPU."
    sleep 4s
    xbps-install -y mesa-dri vulkan-loader mesa-vulkan-radeon amdvlk xf86-video-amdgpu xf86-video-ati mesa-vaapi mesa-vdpau
    else if [[ "${gpu,,}" == *"intel"* ]]; then
        echo "Installing graphics drivers for an Intel GPU."
        sleep 4s
        xbps-install -y mesa-vulkan-intel vulkan-loader intel-video-accel mesa-dri linux-firmware-intel
        else if [[ "${gpu,,}" == *"nvidia"* ]]; then
            echo "Installing graphics drivers for an NVIDIA GPU."
            sleep 4s
            xbps-install -y nvidia nvidia-libs-32bit
            else
            echo "Could not find a supported GPU by that name. Press ctrl+c now to stop install."
            sleep 15s
        fi
    fi
fi

# Install GNOME and important software.
./desktops/gnome.sh

# Install fonts
./extra/fonts.sh

# Install printer drivers (I fucking hate printers so much. Why does not a single good printer exist.)
./extra/printer.sh

# Disable the network management services used in the installer and enable NetworkManager. This is not in the script so I can use ConnMan with Enlightenment.
./extra/NetworkManager.sh

# Enabling important services not started elsewhere
ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/elogind /var/service/
ln -s /etc/sv/bluetoothd /var/service/
ln -s /etc/sv/cronie /var/service/
ln -s /etc/sv/chronyd /var/service/

# Start GDM service and reboot
ln -s /etc/sv/gdm /var/service/
reboot