# MeloMIDI
An interactive wave to midi editor, music transcription software. Supports Linux and Windows.  
Work in progress, but it is feature-complete, and only minor modifications are needed for the first release!  
## Usage
Releases coming soonTM! *link to releases*  
*insert video link and screenshots here*  
### Expect the program to crash
Be sure to save frequently if you're working on a bit larger project, there are NO backups created! Currently we have no unique file format, but you can still save the midi file, and if the program does crash, you can load the wave file back up, continue working from where you left off, and after finishing, copy the first part and second part midi files together with an external program. It's still better than redoing the whole thing.  
### Controls
We try to use the most intuitive shortcuts and mouse controls, but if you get stuck, you can take a look at the in-program help, that lists all of the available ones.  
### Options
MeloMIDI tries to give as much customization in the recognition as possible, so the users can accomodate it to very different pieces of music.  
You can view the description of an option in the options popup, with hovering over the number input box. Feel free to open an issue if something is hard to understand!  
We also try to give sane defaults, so if the defaults yield absolutely trash results, don't be shy about it either :D!  
## Contributing
If you find a bug or have a cool feature request, be sure to open an issue!  
For a basic roadmap you can take a look at [TODO.txt](TODO.txt), but you can still open an issue about a feature that's in there so we can see the interest in it.  
If you would like to create a pull request, please also open an issue first, so that we can talk about it, and if it maybe turns out that it is out of scope or something else, you don't work for nothing.  
## Modifying the program
* download the source code from the **release**s (there are none currently though)  
* download Godot 3.3+ (if you don't already have it)  
* run Godot and open the project with it  
* hit F5 to run the program  
* now you can modify the it and instantly see the changes  
See also [Compiling spectrum_analyzer.cpp](#compiling-spectrum_analyzercpp).  
## Compiling spectrum_analyzer.cpp
There's already a compiled version in `project/bin` in the **release** version of the source code (no releases yet though), and you can modify most parts of the program without changing the GDNative/NativeScript part. See [Modifying the program](#modifying-the-program) for that.  
However, if you want to modify the core (C++) part of the spectrum analyzer (fft calculation, image creation, note recognition algorithms), you need to compile `spectrum_analyzer.cpp` after the modification.  
We use the CMake build system for building. You'll need to install some dependencies if you don't already have them.  
These include: `git` for getting the submodules, `cmake`, then a build system that CMake generates (like `make`), `python` for godot-cpp's binding generation and a C++ compiler like `gcc` or `clang` (or `mingw` or `msvc` for Windows).
After cloning the `main` branch (or downloading the source from the **release**s, that's generally more stable, but older), you need to `git submodule update --init --recursive` inside the root folder (`MeloMIDI` or `MeloMIDI-main`) to get the submodules (the command may be different on Windows).  
### Linux
Then either run `source/build_linux.sh`, or something similar to that.  
### From Linux to Windows
Either run `source/build_windows.sh`, or something similar to that. The toolchain file is provided.  
### Windows
Run CMake, and with that you should either generate a Makefile if you're compiling with MinGW, or generate a Visual Studio thing if you're using MSVC which I know nothing about.  
### Mac
If someone is interested in a Mac port, I'd gladly help, but I can't test it. Compiling `spectrum_analyzer.cpp` and testing are the bottleneck in supporting it, Godot supports it otherwise pretty much out of the box as far as I know.  
## Used software
* [godot](https://github.com/godotengine/godot) game engine 3.3+ for everything  
* [godot-midi-player](https://bitbucket.org/arlez80/godot-midi-player/src/master/) for playing and saving MIDI in GDScript  
* [GDScriptAudioImport](https://github.com/Gianclgar/GDScriptAudioImport) for importing audio at runtime into godot streams  
* [godot-cpp](https://github.com/godotengine/godot-cpp) bindings for high performance calculations and library integration  
* [kissfft](https://github.com/mborgerding/kissfft) for easy to use Fast Fourier Transform calculations  
* [libnyquist](https://github.com/ddiakopoulos/libnyquist) for decompressing audio into raw audio data in C++  
