#!/bin/bash
set -ex

sudo apt -y install cmake libncurses5-dev libncursesw5-dev git
git clone https://github.com/Syllo/nvtop.git
mkdir -p nvtop/build && cd nvtop/build
cmake ..
make

# Install globally on the system
sudo make install

# Alternatively, install without privileges at a location of your choosing
# make DESTDIR="/your/install/path" install
