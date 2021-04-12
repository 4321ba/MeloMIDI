#!/bin/sh
#this is so that you can run the script from other directories too
cd $(dirname $0)
mkdir build_linux
cd build_linux
echo "starting the building for Linux in $PWD"
cmake ..
make -j4
