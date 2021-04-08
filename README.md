# MeloMIDI
An interactive wave to midi editor, music transcription software.  
Work in progress, but it can already save the converted audio; and visualization, playback, note placement, modification and removal, and conversion with options are also working.  
## Usage
Releases coming soonTM!  
*insert video link and screenshots here*  
### Expect the program to crash
Be sure to save frequently if you're working on a bit larger project, there are NO backups created! Currently we have no unique file format, but you can still save the midi file, and if the program does crash, you can load the wave file back up, continue working from where you left off, and after finishing, copy the first part and second part midi files together with an external program. It's still better than redoing the whole thing.  
### Controls
We try to use the most intuitive shortcuts and mouse controls, but if you get stuck, you can take a look at the in-program help, that lists all of the available ones.  
### Options
MeloMIDI tries to give as much customization in the recognition as possible, so the users can accomodate it to very different pieces of music.  
You can view the description of an option in the options popup, with hovering over the number input box. Feel free to open an issue if something is hard to understand!  
We also try to give sane defaults, so if the defaults yield absolutely trash results, don't be shy about it either :D!  
## Modifying the program
You can download this repository, download Godot 3.3+ (if you don't already have it), run Godot and open the project with it. Hit F5 and everything should work as in the release. (currently only Linux, because `spectrum_analyzer.cpp` would need to be compiled for windows to work out of the box) Now you can modify the program and instantly see the changes.  
See also [Compiling spectrum_analyzer.cpp](#compiling-spectrum_analyzercpp).  
## Contributing
If you find a bug or have a cool feature request, be sure to open an issue!  
For a basic roadmap you can take a look at [TODO.txt](TODO.txt), but you can still open an issue about a feature that's in there so we can see the interest in it.  
If you would like to create a pull request, please also open an issue first, so that we can talk about it, and if it maybe turns out that it is out of scope, you don't work for nothing.  
## Compiling spectrum_analyzer.cpp
There's already a compiled version in `project/bin` (currently for Linux only), and you can modify most parts of the program without changing the GDNative/NativeScript part.  
However, if you want to modify the core (C++) part of spectrum_analyzer (fft calculation, image creation, note recognition algorithms), you have to compile/build the libraries first.  
We should have a build system like cmake, but we don't have that yet. (A contribution would be appreciated!)  
### Linux
First you need to `git submodule update --init --recursive` to get the submodules.  
Before building you need to `cd` into the root directory of the library.  
Build the godot-cpp bindings with this command: `scons generate_bindings=yes -j4`, if you have 4 cpu cores e.g..  
For libnyquist and kissfft, you need to edit their `CMakeLists.txt`s and add `set(CMAKE_POSITION_INDEPENDENT_CODE ON)` inside.  
For the kissfft library, create a directory: `mkdir build && cd build`, then it can be built e.g. with this command: `cmake -DKISSFFT_STATIC=ON -DKISSFFT_TEST=OFF -DKISSFFT_TOOLS=OFF ..` and then `make`.  
You can make libnyquist with `cmake .` and `make`, but we could look into its options as we only need a little part of the library, the one that decodes wav, ogg and mp3 into a raw array inside C++, we don't need wavpack, rtaudio, opus, etc.. Mainly, `BUILD_LIBOPUS` and `BUILD_EXAMPLE` could be turned off.  
After that you can try to run `./build.sh` inside the `source` folder, or at least try doing something equivalent. You should get a `.so` file in `project/bin` as a result.  
### From Linux to Windows
I have yet to figure this out.  
### Windows
Try doing something similar to Linux. Also put the path of the `.dll` file into `project/bin/spectrum_analyzer.gdnlib`, it can be added with a GUI in Godot.  
### Mac
If someone is interested in a Mac port, I'd gladly help, but I can't test it. Compiling `spectrum_analyzer.cpp` is the bottleneck in supporting it.  
## Used software
* [godot](https://github.com/godotengine/godot) game engine 3.3+ for everything  
* [godot-midi-player](https://bitbucket.org/arlez80/godot-midi-player/src/master/) for playing and saving MIDI in GDScript  
* [GDScriptAudioImport](https://github.com/Gianclgar/GDScriptAudioImport) for importing audio at runtime into godot streams  
* [godot-cpp](https://github.com/godotengine/godot-cpp) bindings for high performance calculations and library integration  
* [kissfft](https://github.com/mborgerding/kissfft) for easy to use Fast Fourier Transform calculations  
* [libnyquist](https://github.com/ddiakopoulos/libnyquist) for decompressing audio into raw audio data in C++  
