# Local Speech Journal

A private, offline-first journaling application that converts spoken audio into searchable text, allowing users to record their thoughts and easily retrieve them later. This project prioritizes local processing, privacy, and efficient search capabilities.

## Table of Contents
1. [Project Goals](#project-goals)
2. [Core Technologies](#core-technologies)
3. [System Architecture](#system-architecture)
4. [Module Breakdown & Implementation](#module-breakdown--implementation)
    - [Module 1: Audio Capture & Management](#module-1-audio-capture--management)
    - [Module 2: Voice Activity Detection (VAD)](#module-2-voice-activity-detection-vad)
    - [Module 3: Speech-to-Text (Whisper)](#module-3-speech-to-text-whisper)
    - [Module 4: Data Storage & Search (SQLite)](#module-4-data-storage--search-sqlite)
    - [Module 5: User Interface (UI)](#module-5-user-interface-ui)
5. [Integration & Workflow](#integration--workflow)
6. [Build & Setup](#build--setup)
7. [Future Enhancements](#future-enhancements)

## 1. Project Goals

- **Local & Offline:** All processing and storage occur on the user's PC without requiring internet access.
- **Speech-to-Text:** Convert spoken audio recordings into accurate text transcripts.
- **Searchable Journal:** Enable easy text-based searching through recorded entries.
- **Audio Preservation:** Store original audio recordings alongside their transcripts.
- **Privacy-Focused:** No data leaves the user's machine.
- **Efficient:** Optimized for local execution on a laptop.
- **C/C++:** Primarily C/C++ implementation

## 2. Core Technologies

- **Audio Capture:** `PortAudio` (C/C++) or `SDL2` (C/C++)
- **Voice Activity Detection (VAD):** `libfvad` (C)
- **Speech-to-Text:** `whisper.cpp` (C/C++ implementation of OpenAI Whisper)
- **Data Storage:** `SQLite` with FTS5 (Full-Text Search)
- **User Interface (UI):** `Dear ImGui` (C++) for a simple, functional UI, or `Qt`/`GTK` for a more feature-rich desktop experience.
- **Build System:** `Makefile`

## 3. System Architecture

The application will follow a modular design, with data flowing through several stages:

```
[Microphone Input]
       ↓
[Audio Capture Module (PortAudio)]
       ↓ (Raw PCM Audio Buffer)
[Voice Activity Detection Module (libfvad)]
       ↓ (Speech/Silence Events)
[Audio Segmenter & WAV Writer]
       ↓ (Saved WAV File Path)
[Whisper Transcription Module (whisper.cpp)]
       ↓ (Text Transcript + Timestamps)
[Journal Database Module (SQLite)]
       ↓ (Stored Entries: Audio Path, Transcript, Metadata)
       ↑ (Search Queries)
[User Interface (Dear ImGui)]
```

## 4. Module Breakdown & Implementation

### Module 1: Audio Capture & Management

**Purpose:** Continuously capture audio from the microphone, buffer it, and write segments to WAV files when speech is detected.

**Libraries:** `PortAudio` is a good cross-platform choice for low-latency audio I/O.

**Implementation Details:**
- Initialize `PortAudio` to capture 16kHz, mono, 32-bit float PCM audio (Whisper's required format).
- Maintain a circular buffer to store incoming audio. This buffer will be continuously fed to the VAD module.
- When the VAD module signals a speech segment, start writing the buffered audio (and subsequent live audio) to a temporary `.wav` file.
- When VAD signals sustained silence, finalize the current `.wav` file and prepare it for transcription.

**Code Snippet (Conceptual C++):**
```cpp
// AudioRecorder.h
#include <portaudio.h>
#include <vector>
#include <string>
#include <functional>

class AudioRecorder {
public:
    AudioRecorder(std::function<void(const std::vector<float>&)> vadCallback);
    bool startRecording();
    void stopRecording();
    // Callback for PortAudio stream
    static int paCallback(const void* inputBuffer, void* outputBuffer,
                          unsigned long framesPerBuffer,
                          const PaStreamCallbackTimeInfo* timeInfo,
                          PaStreamCallbackFlags statusFlags, void* userData);

    // Method to save a completed audio segment
    std::string saveAudioSegment(const std::vector<float>& audioData);

private:
    PaStream* stream;
    std::vector<float> audioBuffer; // Buffer for continuous recording
    std::function<void(const std::vector<float>&)> vadProcessor;
    // ... other state for managing WAV file writing ...
};
```

### Module 2: Voice Activity Detection (VAD)

**Purpose:** Analyze incoming audio chunks to determine if speech is present, helping to segment recordings and ignore long periods of silence.

**Libraries:** `libfvad` (WebRTC VAD) is lightweight and efficient.

**Implementation Details:**
- `libfvad` operates on small frames (e.g., 20ms). The `AudioRecorder` will pass these frames to the VAD.
- The VAD module will maintain a state (e.g., `isSpeaking`, `silenceDuration`).
- If speech is detected, set `isSpeaking = true` and reset `silenceDuration`.
- If silence is detected while `isSpeaking` is true, increment `silenceDuration`.
- If `silenceDuration` exceeds a predefined threshold (e.g., 2-3 seconds), signal the end of a speech segment.
- This module will trigger the `AudioRecorder` to start/stop saving to a WAV file.

**Code Snippet (Conceptual C++):**
```cpp
// VoiceActivityDetector.h
#include <fvad.h>
#include <vector>
#include <functional>

class VoiceActivityDetector {
public:
    VoiceActivityDetector(int sampleRate, std::function<void(const std::vector<float>&)> onSpeechSegmentEnd);
    void processAudioFrame(const std::vector<float>& frame);

private:
    Fvad* vad;
    std::vector<float> currentSpeechSegment;
    bool speechDetected;
    int silenceFrameCount;
    const int SILENCE_THRESHOLD_FRAMES = 100; // e.g., 2 seconds of 20ms frames
    std::function<void(const std::vector<float>&)> speechSegmentEndCallback;
};
```

### Module 3: Speech-to-Text (Whisper)

**Purpose:** Transcribe the saved audio segments into text.

**Libraries:** `whisper.cpp` provides a C/C++ API for local Whisper inference.

**Implementation Details:**
- Load a pre-trained Whisper model (e.g., `ggml-base.en.bin` or `ggml-small.en.bin`).
- When an audio segment is finalized by the VAD/Audio Capture module, pass its file path (or the raw audio data) to the `WhisperTranscriber`.
- Run the `whisper_full` function to get the transcription.
- Extract the full text and potentially segment-level timestamps.

**Code Snippet (Conceptual C++):**
```cpp
// WhisperTranscriber.h
#include "whisper.h"
#include <string>
#include <vector>

struct TranscriptionResult {
    std::string text;
    // Add timestamp information if needed
};

class WhisperTranscriber {
public:
    WhisperTranscriber(const std::string& modelPath);
    TranscriptionResult transcribeAudio(const std::string& audioFilePath);
    TranscriptionResult transcribeAudio(const std::vector<float>& audioData);

private:
    whisper_context* ctx;
    // ... other configuration ...
};
```

### Module 4: Data Storage & Search (SQLite)

**Purpose:** Persistently store journal entries (audio file path, transcript, timestamp) and enable efficient full-text search.

**Libraries:** `SQLite` is a lightweight, file-based relational database that is perfect for local applications. Enable FTS5 for full-text search.

**Implementation Details:**
- Create a SQLite database file (e.g., `journal.db`).
- Define a table schema: `CREATE TABLE entries (id INTEGER PRIMARY KEY, timestamp TEXT, audio_path TEXT, transcript TEXT);`
- Enable FTS5 for the `transcript` column: `CREATE VIRTUAL TABLE entries_fts USING fts5(transcript, content='entries', content_rowid='id');`
- Implement functions to:
    - Insert new entries.
    - Query entries by date/time.
    - Perform full-text searches using FTS5.

**Code Snippet (Conceptual C++):**
```cpp
// JournalDB.h
#include <sqlite3.h>
#include <string>
#include <vector>

struct JournalEntry {
    int id;
    std::string timestamp;
    std::string audioPath;
    std::string transcript;
};

class JournalDB {
public:
    JournalDB(const std::string& dbPath);
    ~JournalDB();
    bool open();
    void close();
    bool createTables();
    bool insertEntry(const std::string& audioPath, const std::string& transcript);
    std::vector<JournalEntry> searchEntries(const std::string& query);
    std::vector<JournalEntry> getAllEntries();

private:
    sqlite3* db;
    std::string dbFilePath;
};
```

### Module 5: User Interface (UI)

**Purpose:** Provide a simple graphical interface for recording, viewing, and searching journal entries.

**Libraries:** `Dear ImGui` is an excellent choice for a "simple but usable" C++ UI, especially for prototyping, as it's lightweight and easy to integrate with OpenGL/DirectX.

**Implementation Details:**
- Set up an ImGui context with a suitable backend (e.g., OpenGL + GLFW).
- Create UI elements:
    - A "Record" button and a "Stop" button.
    - A display area for the current live transcription (optional, or show "Listening...").
    - A list or table to display past journal entries.
    - A search input field and a display area for search results.
- The UI will interact with the `AudioRecorder` (start/stop), and `JournalDB` (display/search).

**Code Snippet (Conceptual C++ with ImGui):**
```cpp
// main.cpp (UI loop)
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include <GLFW/glfw3.h>
#include "AudioRecorder.h"
#include "VoiceActivityDetector.h"
#include "WhisperTranscriber.h"
#include "JournalDB.h"

void renderUI(AudioRecorder& recorder, JournalDB& db, WhisperTranscriber& transcriber) {
    ImGui::Begin("Local Speech Journal");

    if (ImGui::Button("Start Recording")) {
        recorder.startRecording();
        // Update UI state
    }
    ImGui::SameLine();
    if (ImGui::Button("Stop Recording")) {
        recorder.stopRecording();
        // Trigger transcription and save to DB
    }

    ImGui::Text("Status: %s", "Listening..."); // Example status

    static char searchBuffer = "";
    ImGui::InputText("Search", searchBuffer, sizeof(searchBuffer));
    ImGui::SameLine();
    if (ImGui::Button("Search")) {
        // Perform search via JournalDB and display results
    }

    ImGui::Separator();
    ImGui::Text("Journal Entries:");
    // Display entries from JournalDB

    ImGui::End();
}

int main() {
    // Initialize GLFW, ImGui, PortAudio, Whisper, SQLite
    // ...

    // Main loop
    while (!glfwWindowShouldClose(window)) {
        // Poll events, render ImGui, swap buffers
        // ...
        renderUI(audioRecorder, journalDB, whisperTranscriber);
        // ...
    }
    // Cleanup
    // ...
    return 0;
}
```

## 5. Integration & Workflow

1.  **Application Start:**
   - Initialize `PortAudio`, `libfvad`, `whisper.cpp` context, and `SQLite` database.
   - Load Whisper model.
   - Open the UI window.
2.  **Recording Session:**
   - User clicks "Start Recording" in the UI.
   - `AudioRecorder` starts capturing audio into its internal buffer and passes chunks to `VoiceActivityDetector`.
   - `VoiceActivityDetector` processes chunks. If speech is detected, it signals `AudioRecorder` to start saving to a temporary `.wav` file.
   - If `VoiceActivityDetector` detects sustained silence (e.g., 2 seconds), it signals `AudioRecorder` to finalize the current `.wav` file.
   - The `AudioRecorder` then triggers the `WhisperTranscriber` with the path to the new `.wav` file.
   - `WhisperTranscriber` processes the audio, returns the text.
   - The text and the `.wav` file path are then passed to `JournalDB` for storage.
3.  **User Interaction (UI):**
   - The UI continuously polls `JournalDB` for new entries or displays search results.
   - Search queries from the UI are sent to `JournalDB`, and results are displayed.
   - Users can click on an entry to potentially play the audio or view the full transcript.
   - A background thread or asynchronous processing should be used for Whisper transcription to keep the UI responsive.
   
## 6. Build & Setup

This project uses a standard `Makefile` for building.
```bash
# Clone whisper.cpp and build it (needed for libwhisper.a)
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
make -j$(nproc)

# Download a Whisper model (e.g., base.en)
# From the whisper.cpp directory
./models/download-ggml-model.sh base.en

# Clone libfvad
git clone https://github.com/dpirch/libfvad.git
cd libfvad
# Follow libfvad's build instructions (usually CMake based)
mkdir build && cd build
cmake ..
make

# Install PortAudio (system-wide or build from source)
# On Ubuntu/Debian: sudo apt-get install libportaudio2 libportaudiocpp0 portaudio19-dev
# On macOS: brew install portaudio

# Install SQLite3 (usually system-wide)
# On Ubuntu/Debian: sudo apt-get install sqlite3 libsqlite3-dev
# On macOS: brew install sqlite3

# For Dear ImGui, it's usually added as a submodule or copied directly
# git submodule add https://github.com/ocornut/imgui.git extern/imgui

# Compile the project using the provided Makefile
make

# Run the application
./journal_app

# Example project structure:
# my_journal_app/
# ├── Makefile
# │   ├── main.cpp
# │   ├── AudioRecorder.h
# │   ├── AudioRecorder.cpp
# │   ├── VoiceActivityDetector.h
# │   ├── VoiceActivityDetector.cpp
# │   ├── WhisperTranscriber.h
# │   ├── WhisperTranscriber.cpp
# │   ├── JournalDB.h
# │   ├── JournalDB.hpp
# │   ├── VoiceActivityDetector.hpp
# └── extern/
#     ├── imgui/
#     ├── whisper.cpp/ (symlink or submodule)
#     └── libfvad/ (symlink or submodule)
