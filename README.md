# arloausb

## Intro

A Raspberry Pi Zero W, Raspberry Pi Zero 2 W or Raspberry Pi 4 can emulate a USB drive, so can act as a drive for your Arlo base station to write camera footage to. Because the Raspberry Pi has full access to the emulated drive, it can:
* automatically copy the recordings to an archive server when you get home
* hold both dashcam recordings and music files
* automatically repair filesystem corruption
* serve up a web UI to view or download the recordings
* retain more than one hour of RecentClips (assuming large enough storage)



## Prerequisites

### Hardware

Required:
* [Raspberry Pi Zero W](https://www.raspberrypi.org/products/raspberry-pi-zero-w/) ([Adafruit](https://www.adafruit.com/product/3400) or [Amazon](https://www.amazon.com/s?k=raspberry+pi+zero+w))  
or
[Raspberry Pi Zero 2 W](https://www.raspberrypi.org/products/raspberry-pi-zero-2-w/) ([Adafruit](https://www.adafruit.com/product/5219) or [Amazon](https://www.amazon.com/s?k=raspberry+pi+zero+2+w))  
or
[Raspberry Pi 4](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/) ([Adafruit](https://www.adafruit.com/product/4295) or [Amazon](https://www.amazon.com/s?k=raspberry+pi+4))  
**Note: Of the many varieties of Raspberry Pi available only the Raspberry Pi Zero W, Zero 2 W, and 4 will work with TeslaUSB**.

* A Micro SD card, at least 64 GB in size, and an adapter (if necessary) to connect the card to your computer.
* A mechanism to connect the Pi to Arlo base station: a USB A/Micro B cable for the Pi Zero W, or a USB A/Micro C cable for Pi 4

Optional:
* A case for the Pi Zero. The "Official" case: [Adafruit](https://www.adafruit.com/product/3446) or [Amazon](https://www.amazon.com/gp/product/B06Y593MHV). There are many others to choose from.
* A cooler for the Pi 4. The Raspberry Pi 4 uses much more power than the Pi Zero W, and as a result can get quite hot. The ["armor case"](https://www.amazon.com/s?k=Raspberry+Pi+4+Armor+Case) (available with or without fans) appears to do a good job of protecting the Pi while keeping it cool.
* USB Splitter if you don't want to lose a front USB port. [The Onvian Splitter](https://www.amazon.com/gp/product/B01KX4TKH6) has been reported working by multiple people on reddit.


## Installing

To install arlousb, please use the [prebuilt image](https://github.com/MarMed/arlousb/releases) and [one step setup instructions](doc/OneStepSetup.md).


## Contributing

You're welcome to contribute to this repo by submitting pull requests and creating issues.
For pull requests, please split complex changes into multiple pull requests when feasible, and follow the existing code style.

## Meta

This repo contains steps and scripts originally from [teslausb]( [https://www.reddit.com/r/teslamotors/comments/9m9gyk/build_a_smart_usb_drive_for_your_tesla_dash_cam/](https://github.com/marcone/teslausb))

