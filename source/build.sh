#!/bin/sh
clang++ -fPIC -o spectrum_analyzer.o -c spectrum_analyzer.cpp -g -O3 -std=c++14 -Igodot-cpp/include -Igodot-cpp/include/core -Igodot-cpp/include/gen -Igodot-cpp/godot-headers -Ikissfft -Ilibnyquist/include/libnyquist
clang++ -o ../project/bin/spectrum_analyzer.so -shared spectrum_analyzer.o -Lgodot-cpp/bin -lgodot-cpp.linux.debug.64 -Llibnyquist/bin -llibnyquist -llibwavpack -Lkissfft/build -lkissfft-float
