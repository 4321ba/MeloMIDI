#!/bin/sh
#this is so that you can run the script from other directories too
cd $(dirname $0)
mkdir build_windows
cd build_windows
echo "starting the building for Windows in $PWD"
cmake -DCMAKE_TOOLCHAIN_FILE=../mingw-w64-x86_64.cmake ..
make -j4
#somehow the toolchain's last line only works if I run it twice
cmake -DCMAKE_TOOLCHAIN_FILE=../mingw-w64-x86_64.cmake ..
make -j4
