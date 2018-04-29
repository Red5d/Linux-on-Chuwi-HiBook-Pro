#! /bin/bash

# Script to setup touchscreen driver/firmware on Chuwi HiBook Pro running Ubuntu 18.04

# Install dependencies
sudo apt update
sudo apt install gcc make python3-numpy python3-tk

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

# Build and insert the touchscreen driver kernel module (insert doesn't persist over reboots)
cd gslx680-acpi-master
make
sudo insmod gslx680_ts_acpi.ko

# Get and run xcal for calibrating the touchscreen
cd ..
wget https://github.com/reinderien/xcal/raw/master/xcal
chmod +x ./xcal
./xcal
