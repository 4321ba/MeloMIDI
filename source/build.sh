#!/bin/sh
#this is so that you can run the script from other directories too
cd $(dirname $0)/build
echo "starting the building for Linux in $PWD"
cmake ..
make -j4
