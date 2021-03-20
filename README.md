# MeloMIDI
An interactive wave to midi editor.
# Compiling
If you want to modify the core (C++) part of spectrum_analyzer, you have to compile/build the libraries first.  
We should have a build system like cmake, but we don't have that yet.  
First you need to `git submodule update --init --recursive` to get the submodules.  
Before building you need to `cd` into the root directory of the library.  
Build the godot-cpp bindings with this command: `scons generate_bindings=yes -j4`, if you have 4 cpu cores e.g..  
For libnyquist and kissfft, you need to edit their `CMakeLists.txt`s and add `set(CMAKE_POSITION_INDEPENDENT_CODE ON)` inside.  
For the kissfft library, create a directory: `mkdir build && cd build`, then it can be built e.g. with this command: `cmake -DKISSFFT_STATIC=ON -DKISSFFT_TEST=OFF -DKISSFFT_TOOLS=OFF ..` and then `make`.  
You can make libnyquist with `cmake .` and `make`, but someone could look into its options as we only need a little part of the library, the one that decodes wav, ogg and mp3 into a raw array inside C++, we don't need wavpack, rtaudio, opus, etc..  
After that you can try to run `./build.sh` inside the `source` folder, or at least try doing something equivalent. You should get a `.so` or `.dll` file in `project/bin` as a result.
