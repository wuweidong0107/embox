# Usage:

$ ./embox_packages.sh <Index or ID>

This will run the actions depends, sources, build, install, configure and clean automatically.

Alternatively, ./embox_packages.sh can be called as:

$ ./embox_packages.sh <Index or ID> [depends|sources|build|install|configure|clean|remove]

## Definitions:
- depends:    install the dependencies for the module
- sources:    install the sources for the module
- build:      build/compile the module
- install:    install the compiled module
- configure:  configure the installed module
- clean:      remove the sources/build folder for the module
- help:       get additional help on the module


# List of valid packages and supported commands:

| Index/ID | Description | List of available actions |
| ----------- | ----------- | ----------- |
100/fa-rk3328-linux-5_4 | kernel for friendlyelec rk3328                     | build depends install sources upgrade_tf upgrade_usb help |
101/fa-rk3399-linux-4_19| kernel for friendlyelec rk3399                     | build depends install sources help |
102/fa-rk3399-linux-4_4 | kernel for friendlyelec rk3399                     | build depends install sources help |
103/fa-rk3399-uboot-2014| u-boot for friendlyelec rk3399                     | build depends install sources help |
104/fa-toolchain        | fa-toolchain                                       | install sources help |
105/linaro-toolchain    | linaro-toolchain                                   | sources help |
200/devmem2             | devmem2 - physical memory access tool.             | build install sources help |
201/fb-test-app         | fb-test-app - framebuffer test tools               | build install sources help |
202/i2c-tools           | i2c-tools - a set of I2C tools for Linux           | build install sources help |
203/kmscube             | kmscube - bare metal graphics demo                 | build depends install sources help |
204/lcdhat              | lcdhat - app for NanoPi NEO3's LCD HAT             | build install sources help |
205/nanohat-oled        | nanohat-oled - physical memory access tool.        | build install sources help |
206/tinyalsa            | tinyalsa - library to interface with ALSA          | build install sources help |
207/triggerhappy        | triggerhappy - A lightweight hotkey daemon.        | build install sources help |
208/WiringNP            | WiringNP - a GPIO access library for NanoPi-H3/H5  | build install sources help |
300/qt                  | qt - a cross-platform application development framework | build depends install sources help |
700/romfetcher          | romfetcher - A very easy rom downloader implemented for RetroPie | build depends install sources help |
800/dtc                 | Device Tree Compiler                               | build depends install sources help |
801/retroarch           | RetroArch - frontend to the libretro cores         | build depends install sources help |
802/inih                | inith - simple .INI file parser in C               | build depends install sources help |
803/lr-fbneo            | Arcade emu - FinalBurn Neo port for libretro       | build install sources help |
804/retroarch           | RetroArch - frontend to the libretro cores         | build depends install sources help |
900/setup               | GUI based setup for embox                          | gui package packages_gui section_gui help |
