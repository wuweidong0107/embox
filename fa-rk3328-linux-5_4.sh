#!/bin/bash

./embox_packages.sh fa-rk3328-linux-5_4 build
./embox_packages.sh fa-rk3328-linux-5_4 install image
./embox_packages.sh fa-rk3328-linux-5_4 upgrade_ssh 192.168.1.158 image
