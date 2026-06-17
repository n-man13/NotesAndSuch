cmake_minimum_required(VERSION 3.15)
project(LocalSpeechJournal LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Dependencies ---

# 1. SQLite3
find_package(SQLite3 REQUIRED)

# 2. PortAudio
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(PORTAUDIO portaudio-2.0)
endif()
if(NOT PORTAUDIO_FOUND)
    find_path(PORTAUDIO_INCLUDE_DIR portaudio.h)
    find_library(PORTAUDIO_LIBRARY portaudio)
endif()

# 3. GLFW & OpenGL (for ImGui)
find_package(glfw3 REQUIRED)
find_package(OpenGL REQUIRED)

# 4. External Submodules
# Add whisper.cpp
add_subdirectory(extern/whisper.cpp EXCLUDE_FROM_ALL)

# Add libfvad
add_subdirectory(extern/libfvad EXCLUDE_FROM_ALL)

# --- Project Structure ---

include_directories(
    .
    ${SQLITE3_INCLUDE_DIRS}
    ${PORTAUDIO_INCLUDE_DIRS}
    ${OPENGL_INCLUDE_DIR}
    extern/whisper.cpp/include
    extern/libfvad/include
    extern/imgui
    extern/imgui/backends
)

# Collect ImGui source files
file(GLOB IMGUI_SOURCES 
    "extern/imgui/*.cpp"
    "extern/imgui/backends/imgui_impl_glfw.cpp"
    "extern/imgui/backends/imgui_impl_opengl3.cpp"
)

add_executable(${PROJECT_NAME} 
    main.cpp
    ${IMGUI_SOURCES}
)

# --- Linking ---

target_link_libraries(${PROJECT_NAME} 
    PRIVATE 
    whisper
    fvad
    SQLite::SQLite3
    ${PORTAUDIO_LIBRARIES}
    glfw
    OpenGL::GL
)

# Platform specific linking
if(WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE shell32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE _CRT_SECURE_NO_WARNINGS)
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE pthread dl)
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")