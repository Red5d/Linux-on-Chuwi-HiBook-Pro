# Linux on the Chuwi HiBook Pro

Tested with Ubuntu 18.04. Antergos worked too when running from a live USB stick, but I encountered a bug or something in the Antergos installer that prevented the install from finishing.

WiFi works perfectly out-of-the-box.

Things that don't work out-of-the-box:
* Touchscreen - working with the method below
* Bluetooth - In progress... Testing some drivers.
* Audio - Read about some possible fixes, but haven't gotten to this yet.
* Cameras - TBD

The accelerometer that controls screen rotation partially works. In landscape orientation, it flips the screen upside down. Portrait mode is rotated correctly though. As a workaround for landscape, hold the screen with the top edge facing the floor so it rotates "correctly", then click the rotation lock button from the upper-right dropdown menu and you can bring it right-side up again and it will stay that way.

You can also run this xrandr command to flip the screen right-side up:

    xrandr --output eDP-1 --rotate normal

I've also read comments that the micro-HDMI port works, but doesn't output sound over HDMI. I haven't personally tested this yet.

I initially started testing with a live USB stick, keyboard, and mouse connected through a powered USB hub to the micro-USB port on the device (powered hub required since the device doesn't output enough power through micro-USB to run anything but a flash drive), but this was rather impractical since I had wires going everywhere and didn't have a good way to hold the device up conveniently while plugged into micro-USB and USBc power, so I got this docking keyboard for it that connects using the POGO pins and holds it in place with some metal tabs and strong magnets: https://www.amazon.com/gp/product/B01F8SSOPG/

It also adds a touchpad, 2 full-size USB2 ports, and a magnet that triggers the "screen closed" action on the device to turn off the screen like a laptop does when you close it.

## Touchscreen

**TL;DR:** If you just want it to work, and you're on Ubuntu 18.04, run the **hibook-pro-ts-setup.sh** script from this repo to download the firmware I extracted/converted, and the kernel driver module I compiled for this and it will setup both of those and run the calibration tool.

If you're not on Ubuntu 18.04, the kernel module *might* still work, but to be sure and build it yourself, run the **hibook-pro-ts-build-setup.sh** script from this repo instead. It will do the setup just like the other script, but will also build the kernel module and convert the firmware from the Windows version.

---

Two things are needed to enable the touchscreen. The firmware file and the kernel module driver for it.

The touchscreen uses a Silead GSLx680-series controller. Some people seem to have been able to get it working with the silead driver built into the kernel after adding the firmware, but it didn't work for me.

I got the SileadTouch.sys Windows firmware for the touchscreen from the C109K_HiBook_Pro_Drivers.zip file linked on this official post in the Chuwi forum:

https://forum.chuwi.com/forum.php?mod=viewthread&tid=2009

Then, I used fwtool from the "tools" folder in the following repo to convert it to the format that Linux needs and set some parameters to flip the y-axis and set the screen resolution:

    git clone https://github.com/onitake/gsl-firmware.git
    cd gsl-firmware/tools
    ./fwtool -c ../../SileadTouch.sys -3 -m 1680 -w 2560 -h 1600 -t 10 -f track,yflip ../../silead_ts.fw

Next, I installed the "gcc" and "make" packages, downloaded the kernel module driver, compiled, and inserted the module:

    git clone https://github.com/onitake/gslx680-acpi.git
    cd gslx680-acpi
    make
    sudo insmod gslx680_ts_acpi.ko

This activated the touchscreen, and it accepted touch input, but still needed calibration. The usual xinput_calibrator tool for calibrating touchscreens on Linux doesn't seem to work on this one, so for that, I used the xcal python script from here:

https://github.com/reinderien/xcal

It requires the python3-tk and python3-numpy packages. The xcal script automates a process of calculating touch coordinate values for the screen which is described on this page: https://wiki.archlinux.org/index.php/Talk:Calibrating_Touchscreen

Run it with *./xcal* and after answering the configuration questions, it will open a fullscreen window with points to tap on the screen to perform the calibration.

After the calibration is complete, the new settings can be applied, and the script will output the calibration matrix values that were set. If you put these values into an xinput command in a script or service that runs automatically on boot, they will be set automatically in the future. See the link below for instructions on putting the matrix values into an xinput command: https://wiki.archlinux.org/index.php/Calibrating_Touchscreen#Apply_the_Matrix

Once the touchscreen is operational and calibrated, it seems to work pretty well. You can also use [Gnome's touchscreen gestures](https://help.gnome.org/misc/release-notes/3.14/touchscreen-gestures.html.en) with it. The "message tray" that page refers to is the onscreen keyboard that you can activate.

Firefox needs an environment variable set in order for touchscreen scrolling to work properly though: https://askubuntu.com/questions/853910/ubuntu-16-and-touchscreen-scrolling-in-firefox


## Bluetooth

The WiFi and Bluetooth interfaces are both on the rtl8723bs chip. The Bluetooth part doesn't work out-of-the-box, but this firmware and script might work:

https://github.com/lwfinger/rtl8723bs_bt

I'm testing this and will update if/when I get it working.

Discussion about Linux Wifi/Bluetooth/Audio drivers for the similar Chuwi vi8 device: https://github.com/Manouchehri/vi8/issues/2

## Audio

## Accelerometer

This "sensor-proxy" tool might be able to fix the auto screen rotation issue mentioned above: https://github.com/hadess/iio-sensor-proxy


## Misc. Resources

Here are some other resources that I used in figuring some of this out.

### Linux setup

https://github.com/kszere/Linux-For-CHUWI-HiBook-Pro - Work In Progress

https://github.com/Split7fire/linux_on_chuwi_hibook

#### Linux on other Chuwi devices

The hardware for some other Chuwi devices like the Hi10 is similar to the HiBook Pro and these links helped me in figuring out some things like the touchscreen firmware/driver settings.

https://github.com/onitake/gslx680-acpi/issues/20

https://txlab.wordpress.com/2017/03/11/running-ubuntu-on-chuwi-hi10-pro-tablet/

https://jonathansblog.co.uk/ubuntu-on-the-chuwi-hi10-pro


## Removing Android and Re-installing Windows only

The Android version for the Chuwi devices is pretty old, and I wanted space on the internal storage for Linux, but wanted to keep Windows on there too for dual-boot, so I first tried just removing all the Android partitions, but that broke the Windows bootloader.

To restore Windows, I downloaded the Windows image from the [official Chuwi forum thread](https://forum.chuwi.com/forum.php?mod=viewthread&tid=2009) (The Z8350 version), and followed their [tutorial for flashing Windows on the Hi8 Pro](https://forum.chuwi.com/forum.php?mod=viewthread&tid=1271) (different device, yes, but the process is the same). However, I modified the installation script to a "SingleOS" configuration where it would install Windows only and not account for an Android installation (you can shrink the Windows partition later to make space for Linux). The steps for this are documented here: https://forum.chuwi.com/forum.php?mod=viewthread&tid=5449 (listed in the forum section for the Hi8 Pro device, but again, the steps are the same for the HiBook Pro)
