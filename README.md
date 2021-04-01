# MeloMIDI
An interactive wave to midi editor, music transcription software.  
Work in progress, but it can already save the converted audio; and visualization, playback, note placement, modification and removal, and conversion with options are also working.  
# Download
Releases coming soonTM!  
If you're adventurous, you can clone the repository and open it in Godot 3.3+ (currently in Release Candidate). For Linux, you (hopefully) don't even need to compile spectrum_analyzer.cpp.  
# Options
MeloMIDI tries to give as much customization in the recognition as possible, so the users can accomodate it to very different pieces of music.  
You can view the description of an option in the options popup, with hovering over the number input box. Feel free to open an issue if something is hard to understand!  
We also try to give sane defaults, so if the defaults yield absolutely trash results, don't be shy about it either :D!  
# Compiling spectrum_analyzer.cpp
There's already a compiled version in `project/bin` (currently for Linux only), and you can modify most parts of the program without changing the GDNative/NativeScript part.  
However, if you want to modify the core (C++) part of spectrum_analyzer (fft calculation, image creation, note recognition), you have to compile/build the libraries first.  
We should have a build system like cmake, but we don't have that yet. (A contribution would be appreciated!)  
## Linux
First you need to `git submodule update --init --recursive` to get the submodules.  
Before building you need to `cd` into the root directory of the library.  
Build the godot-cpp bindings with this command: `scons generate_bindings=yes -j4`, if you have 4 cpu cores e.g..  
For libnyquist and kissfft, you need to edit their `CMakeLists.txt`s and add `set(CMAKE_POSITION_INDEPENDENT_CODE ON)` inside.  
For the kissfft library, create a directory: `mkdir build && cd build`, then it can be built e.g. with this command: `cmake -DKISSFFT_STATIC=ON -DKISSFFT_TEST=OFF -DKISSFFT_TOOLS=OFF ..` and then `make`.  
You can make libnyquist with `cmake .` and `make`, but someone could look into its options as we only need a little part of the library, the one that decodes wav, ogg and mp3 into a raw array inside C++, we don't need wavpack, rtaudio, opus, etc..  
After that you can try to run `./build.sh` inside the `source` folder, or at least try doing something equivalent. You should get a `.so` file in `project/bin` as a result.  
## Windows
Try doing something similar to Linux. Also put the path into the `.dll` file into `project/bin/spectrum_analyzer.gdnlib`, it can be added with a GUI in Godot.  
## From Linux to Windows
I have yet to figure this out.  
## Mac
If someone is interested I'd gladly help, but I can't test it.  
# Used software
[godot](https://github.com/godotengine/godot) game engine 3.3+ for everything  
[godot-midi-player](https://bitbucket.org/arlez80/godot-midi-player/src/master/) for playing and saving MIDI in GDScript  
[GDScriptAudioImport](https://github.com/Gianclgar/GDScriptAudioImport) for importing audio at runtime into godot streams  
[godot-cpp](https://github.com/godotengine/godot-cpp) bindings for high performance calculations and library integration  
[kissfft](https://github.com/mborgerding/kissfft) for easy to use Fast Fourier Transform calculations  
[libnyquist](https://github.com/ddiakopoulos/libnyquist) for decompressing audio into raw audio data in C++  
