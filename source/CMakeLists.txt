#it can probably be lower, but this is what I have
cmake_minimum_required(VERSION 3.16.3)

#name the project and the output file
project(spectrum_analyzer)

#this is the -fPIC option
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

#set the c++ standard to c++14
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

#the position of the output file for the .so and the .dll
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../project/bin")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../project/bin")


#adding the other CMakeLists.txts with some options
set(CMAKE_BUILD_TYPE "Release")
add_subdirectory(godot-cpp)

set(KISSFFT_STATIC ON CACHE BOOL "Build kissfft as static (ON) or shared library (OFF)")
set(KISSFFT_TEST OFF CACHE BOOL "Build kissfft tests")
set(KISSFFT_TOOLS OFF CACHE BOOL "Build kissfft command-line tools")
add_subdirectory(kissfft)

set(BUILD_LIBOPUS OFF)
set(BUILD_EXAMPLE OFF CACHE BOOL "Build example application")
add_subdirectory(libnyquist)


#adding the source file as a shared library (.so or .dll)
add_library(${PROJECT_NAME} SHARED spectrum_analyzer.cpp)
#we need to run godot-cpp's cmake first, because it generates the headers with python
add_dependencies(${PROJECT_NAME} godot-cpp kissfft libnyquist)

#these are the directories of the includes inside the source file
target_include_directories(${PROJECT_NAME} PUBLIC
                            ${CMAKE_SOURCE_DIR}/godot-cpp/include
                            ${CMAKE_SOURCE_DIR}/godot-cpp/include/core
                            ${CMAKE_BINARY_DIR}/godot-cpp/include/gen
                            ${CMAKE_SOURCE_DIR}/godot-cpp/godot-headers
                            ${CMAKE_SOURCE_DIR}/kissfft
                            ${CMAKE_SOURCE_DIR}/libnyquist/include/libnyquist
                            )


#we need to guess the correct name for godot-cpp (godot.os.build_type.system_bits)
set(BITS 32)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(BITS 64)
endif(CMAKE_SIZEOF_VOID_P EQUAL 8)
string(TOLOWER ${CMAKE_SYSTEM_NAME} SYSTEM_NAME)
string(TOLOWER ${CMAKE_BUILD_TYPE} BUILD_TYPE)

#these are the paths where the compiled static libraries are, for godot-cpp, kissfft and libnyquist respectively
target_link_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/bin ${CMAKE_BINARY_DIR}/kissfft ${CMAKE_BINARY_DIR}/bin)

#and we link the libraries, note that libnyquist's and libwavpack's files are called liblibnyquist(.a) and liblibwavpack(.a)
target_link_libraries(${PROJECT_NAME} godot-cpp.${SYSTEM_NAME}.${BUILD_TYPE}.${BITS} libnyquist libwavpack kissfft-float)
