# MeloMIDI
An interactive wave to midi editor.
Work in progress, it can't save the converted audio yet, but visualization, playback, note placement, modification and removal, and experimental conversion is working.
# Compiling spectrum_analyzer.cpp
There's already a compiled version in `project/bin`, and you can modify most parts of the program without changing the GDNative/NativeScript part.  
However, if you want to modify the core (C++) part of spectrum_analyzer (fft calculation, image creation, note recognition), you have to compile/build the libraries first.  
We should have a build system like cmake, but we don't have that yet. A contribution would be welcome!  
## Linux
First you need to `git submodule update --init --recursive` to get the submodules.  
Before building you need to `cd` into the root directory of the library.  
Build the godot-cpp bindings with this command: `scons generate_bindings=yes -j4`, if you have 4 cpu cores e.g..  
For libnyquist and kissfft, you need to edit their `CMakeLists.txt`s and add `set(CMAKE_POSITION_INDEPENDENT_CODE ON)` inside.  
For the kissfft library, create a directory: `mkdir build && cd build`, then it can be built e.g. with this command: `cmake -DKISSFFT_STATIC=ON -DKISSFFT_TEST=OFF -DKISSFFT_TOOLS=OFF ..` and then `make`.  
You can make libnyquist with `cmake .` and `make`, but someone could look into its options as we only need a little part of the library, the one that decodes wav, ogg and mp3 into a raw array inside C++, we don't need wavpack, rtaudio, opus, etc..  
After that you can try to run `./build.sh` inside the `source` folder, or at least try doing something equivalent. You should get a `.so` or `.dll` file in `project/bin` as a result.
