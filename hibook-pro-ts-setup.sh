#! /bin/bash

# Script to setup touchscreen driver/firmware on Chuwi HiBook Pro running Ubuntu 18.04

# Update and install dependencies
sudo apt update
sudo apt install -y python3-numpy python3-tk

# Get touchscreen calibration script
wget https://github.com/reinderien/xcal/raw/master/xcal
chmod +x ./xcal

# Download firmware and kernel module
wget https://github.com/Red5d/Linux-on-Chuwi-HiBook-Pro/raw/master/silead_ts.fw
wget https://github.com/Red5d/Linux-on-Chuwi-HiBook-Pro/raw/master/gslx680_ts_acpi.ko

# Copy firmware to the firmware folder
sudo cp silead_ts.fw /lib/firmware

# Insert kernel module (doesn't persist over reboots)
sudo insmod gslx680_ts_acpi.ko

# Run calibration
./xcal
