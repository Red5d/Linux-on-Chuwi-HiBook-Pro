#! /bin/bash

# Script to setup touchscreen driver/firmware on Chuwi HiBook Pro running Archlinux (tested on Antergos)

# Install dependencies
sudo pacman -S gcc make

# Get the firmware tools and driver
wget https://github.com/onitake/gsl-firmware/archive/master.zip
unzip master.zip
rm master.zip
wget https://github.com/onitake/gslx680-acpi/archive/master.zip
unzip master.zip
rm master.zip

# Get the Windows touchscreen driver and convert it to the right format/settings for Linux
wget https://github.com/Red5d/Linux-on-Chuwi-HiBook-Pro/raw/master/SileadTouch.sys
cd gsl-firmware-master/tools
./fwtool -c ../../SileadTouch.sys -3 -m 1680 -w 2560 -h 1600 -t 10 -f track,yflip ../../silead_ts.fw
cd -

# Copy the driver into the firmware folder
sudo cp silead_ts.fw /lib/firmware

# Build and insert the touchscreen driver kernel module
cd gslx680-acpi-master
make
sudo insmod gslx680_ts_acpi.ko

# Install kernel module so it will be loaded on future boots.
sudo make install

echo "Apply a known-good touch calibration? (y = yes, n = run calibration): "
read yesno
if [ "$yesno" == "y" ];then
  wget https://github.com/Red5d/Linux-on-Chuwi-HiBook-Pro/raw/master/98-touchscreen-calibration.rules
  sudo mv 98-touchscreen-calibration.rules /etc/udev/rules.d/
  sudo udevadm control --reload-rules && sudo udevadm trigger
  echo "Done. Log out and back in or reboot to apply the calibration."
else
  # Get xcal and dependencies, and run xcal for calibrating the touchscreen
  sudo pacman -S tk python-numpy
  cd ..
  wget https://github.com/reinderien/xcal/raw/master/xcal
  chmod +x ./xcal
  ./xcal
fi

