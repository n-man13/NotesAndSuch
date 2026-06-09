cmake_minimum_required(VERSION 3.10)
project(LocalSpeechJournal CXX C)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# External library paths (adjust if your directory structure differs)
set(WHISPER_PATH ${CMAKE_CURRENT_SOURCE_DIR}/extern/whisper.cpp)
set(FVAD_PATH ${CMAKE_CURRENT_SOURCE_DIR}/extern/libfvad)

# Include directories
include_directories(
    .
    ${WHISPER_PATH}
    ${FVAD_PATH}/include
)

# Linker flags and library search paths
link_directories(
    ${WHISPER_PATH}
    ${FVAD_PATH}/build
)

# Dependencies
find_package(Threads REQUIRED)

# PortAudio and SQLite3 usually found via system package managers
# We can use PkgConfig as a robust way to find them
find_package(PkgConfig REQUIRED)
pkg_check_modules(PORTAUDIO REQUIRED portaudio-2.0)
pkg_check_modules(SQLITE3 REQUIRED sqlite3)

include_directories(${PORTAUDIO_INCLUDE_DIRS} ${SQLITE3_INCLUDE_DIRS})
link_directories(${PORTAUDIO_LIBRARY_DIRS} ${SQLITE3_LIBRARY_DIRS})

# Define the executable
add_executable(journal_app main.cpp)

# Link libraries
target_link_libraries(journal_app
    whisper
    fvad
    ${PORTAUDIO_LIBRARIES}
    ${SQLITE3_LIBRARIES}
    Threads::Threads
    ${CMAKE_DL_LIBS}
)

message(STATUS "Build configured for journal_app")
