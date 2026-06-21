# Local Speech Journal

A privacy-respecting journaling application that converts spoken audio into searchable, organized text. Audio can be recorded live or imported from existing files. Transcripts are grouped into sessions, stored as Markdown, and optionally refined overnight by an AI model running on a private server you control.

## Table of Contents
1. [Project Goals](#project-goals)
2. [Core Technologies](#core-technologies)
3. [System Architecture](#system-architecture)
4. [Module Breakdown & Implementation](#module-breakdown--implementation)
    - [Module 1a: Audio Capture (Live)](#module-1a-audio-capture-live)
    - [Module 1b: Audio Import](#module-1b-audio-import)
    - [Module 2: Voice Activity Detection (VAD)](#module-2-voice-activity-detection-vad)
    - [Module 3: Speech-to-Text (Whisper)](#module-3-speech-to-text-whisper)
    - [Module 4: Data Storage & Search (SQLite)](#module-4-data-storage--search-sqlite)
    - [Module 5: User Interface (UI)](#module-5-user-interface-ui)
    - [Module 6: AI Refiner (Remote)](#module-6-ai-refiner-remote)
5. [Session Grouping Logic](#session-grouping-logic)
6. [Titling](#titling)
7. [Integration & Workflow](#integration--workflow)
8. [Build & Setup](#build--setup)
9. [A Note for C → C++ Learners](#a-note-for-c--c-learners)
10. [Future Enhancements](#future-enhancements)

## 1. Project Goals

- **Local-First:** Audio, transcripts, and the database all live on the user's machine. The only data that ever leaves the machine is text sent to a user-configured AI refinement endpoint, entirely opt-in.
- **Flexible Input:** Record live via microphone, or import pre-recorded audio files.
- **Speech-to-Text:** Convert spoken audio into accurate text transcripts.
- **Session-Based Organization:** Automatically group related recordings into sessions, splitting on long gaps.
- **Searchable Journal:** Full-text search across titles and transcripts.
- **Audio Preservation:** Store original audio alongside transcripts.
- **Efficient:** Optimized for local execution on a laptop.
- **Cross-Platform:** Supports Windows and Linux using C++17 and CMake.

## 2. Core Technologies

- **Audio Capture:** `PortAudio` (C/C++) for live mic input.
- **Audio Import/Decoding:** `libsndfile` (C) for reading WAV and FLAC — the only two formats the app needs to accept on import.
- **Voice Activity Detection (VAD):** `libfvad` (C), used both live and over imported files (to find pause boundaries for sectioning).
- **Speech-to-Text:** `whisper.cpp` (C/C++ implementation of OpenAI Whisper).
- **Data Storage:** `SQLite` with FTS5 (Full-Text Search).
- **User Interface (UI):** `Dear ImGui` (C++).
- **AI Refinement:** Remote HTTP call to a self-hosted `llama-server` (llama.cpp) instance, speaking an Anthropic-style `/v1/messages` request shape. Endpoint is user-configurable, not hardcoded.
- **HTTP Client:** A lightweight C/C++ HTTP library (e.g. `libcurl`) for talking to the refiner endpoint.
- **Build System:** `CMake`

## 3. System Architecture

```
[Microphone Input]              [Imported Audio File]
       ↓                                ↓
[AudioRecorder (PortAudio)]     [AudioImporter (libsndfile: WAV/FLAC)]
       ↓ (PCM buffer)                   ↓ (PCM buffer, decoded)
       └───────────────┬────────────────┘
                        ↓
          [Voice Activity Detector (libfvad)]
                        ↓ (speech segments + pause durations)
          [Audio Segmenter & WAV Writer]
                        ↓ (saved audio file path)
          [Whisper Transcription (whisper.cpp)]
                        ↓ (raw text + timestamps)
          [Session Assignment (3hr gap rule)]
                        ↓
          [Journal Database (SQLite)] ←── stores session + segment metadata
                        ↓
          [transcript_raw.md per session]
                        ↓ (overnight / on catch-up)
          [AI Refiner (remote llama-server)]
                        ↓
          [transcript.md — sectioned by topic/pause]
                        ↓
          [User Interface (Dear ImGui)] ←── search queries, playback, editing
```

## 4. Module Breakdown & Implementation

### Module 1a: Audio Capture (Live)

**Purpose:** Continuously capture audio from the microphone, buffer it, and write segments to WAV files when speech is detected.

**Libraries:** `PortAudio`.

**Implementation Details:**
- Capture 16kHz, mono, 32-bit float PCM audio (Whisper's required format).
- Maintain a circular buffer fed continuously to the VAD module.
- Use `std::filesystem` for cross-platform path handling.
- On VAD speech-start signal, begin writing to a temporary `.wav` file; on sustained-silence signal, finalize it.

**Code Snippet (Conceptual C++):**
```cpp
// AudioRecorder.h
#include <portaudio.h>
#include <filesystem>
#include <string>
#include <functional>
#include <memory>

class AudioRecorder {
public:
    AudioRecorder(std::function<void(const std::vector<float>&)> vadCallback);
    bool startRecording();
    void stopRecording();

    static int paCallback(const void* inputBuffer, void* outputBuffer,
                          unsigned long framesPerBuffer,
                          const PaStreamCallbackTimeInfo* timeInfo,
                          PaStreamCallbackFlags statusFlags, void* userData);

    std::string saveAudioSegment(const std::vector<float>& audioData);

private:
    // Wrap the raw PaStream* with a unique_ptr + custom deleter so it's
    // automatically closed even if an exception unwinds the stack.
    std::unique_ptr<PaStream, void(*)(PaStream*)> stream;
    std::vector<float> audioBuffer;
    std::function<void(const std::vector<float>&)> vadProcessor;
};
```

### Module 1b: Audio Import

**Purpose:** Allow the user to bring in pre-recorded audio files (not captured live) and feed them into the same downstream pipeline (VAD → Whisper → DB) as live recordings.

**Libraries:** `libsndfile`. The app only needs to accept WAV and FLAC on import — no need to handle arbitrary formats (mp3, m4a, ogg, etc.), so no `ffmpeg` dependency is required.

**Implementation Details:**
- User selects a file via the UI's "Import Audio" button.
- `AudioImporter` decodes/resamples the file to the same PCM format used by live capture, so it can reuse the existing VAD and Whisper code paths unchanged.
- Run VAD over the entire imported file (not for live start/stop control, but to locate pause boundaries — needed later for AI sectioning).
- The user supplies (or the file's metadata provides) a recording timestamp, since imported files don't have a "live" capture time.
- Each resulting audio segment is tagged `source = 'imported'` in the database so the origin is traceable.

**Code Snippet (Conceptual C++):**
```cpp
// AudioImporter.h
#include <string>
#include <vector>
#include <optional>
#include <chrono>

struct ImportedAudio {
    std::vector<float> pcmData;     // decoded to 16kHz mono float32
    std::chrono::system_clock::time_point timestamp; // user-supplied or from file metadata
};

class AudioImporter {
public:
    // Returns std::nullopt on decode failure (unsupported/corrupt file)
    std::optional<ImportedAudio> importFile(
        const std::string& filePath,
        std::optional<std::chrono::system_clock::time_point> userTimestamp = std::nullopt
    );
};
```

### Module 2: Voice Activity Detection (VAD)

**Purpose:** Analyze audio chunks to determine speech presence, used for (a) live segmenting/silence-trimming and (b) locating pause boundaries in any audio, live or imported, for later topic sectioning.

**Libraries:** `libfvad` (WebRTC VAD).

**Implementation Details:**
- Operates on small frames (e.g., 20ms).
- Maintains state (`isSpeaking`, `silenceDuration`).
- On sustained silence (e.g., 2-3 seconds), signals end of a speech segment and reports the **pause duration** preceding it — this value gets stored per-segment for use during AI refinement (a 90-second pause is a much stronger "new topic" signal than a 3-second breath).

**Code Snippet (Conceptual C++):**
```cpp
// VoiceActivityDetector.h
#include <fvad.h>
#include <vector>
#include <functional>

struct SpeechSegmentResult {
    std::vector<float> audio;
    int precedingSilenceSeconds;
};

class VoiceActivityDetector {
public:
    VoiceActivityDetector(int sampleRate, std::function<void(const SpeechSegmentResult&)> onSpeechSegmentEnd);
    void processAudioFrame(const std::vector<float>& frame);

private:
    Fvad* vad;
    std::vector<float> currentSpeechSegment;
    bool speechDetected;
    int silenceFrameCount;
    const int SILENCE_THRESHOLD_FRAMES = 100; // ~2 seconds at 20ms/frame
    std::function<void(const SpeechSegmentResult&)> speechSegmentEndCallback;
};
```

### Module 3: Speech-to-Text (Whisper)

**Purpose:** Transcribe saved audio segments into text.

**Libraries:** `whisper.cpp`.

**Implementation Details:**
- Load a pre-trained Whisper model (e.g., `ggml-base.en.bin`).
- Run `whisper_full` on each finalized segment (live or imported).
- Output is appended to the session's `transcript_raw.md` — see [Module 4](#module-4-data-storage--search-sqlite) for how segments map to sessions.

**Code Snippet (Conceptual C++):**
```cpp
// WhisperTranscriber.h
#include "whisper.h"
#include <string>
#include <vector>
#include <memory>

struct TranscriptionResult {
    std::string text;
};

class WhisperTranscriber {
public:
    WhisperTranscriber(const std::string& modelPath);
    TranscriptionResult transcribeAudio(const std::string& audioFilePath);
    TranscriptionResult transcribeAudio(const std::vector<float>& audioData);

private:
    std::unique_ptr<whisper_context, void(*)(whisper_context*)> ctx;
};
```

### Module 4: Data Storage & Search (SQLite)

**Purpose:** Persistently store **sessions** (journal entries) and the individual **audio segments** that make them up, and enable full-text search across titles and transcripts.

A single "journal entry" the user sees is a **session** — potentially built from multiple recordings (live or imported) that fall within 3 hours of each other. See [Section 5](#session-grouping-logic) for the grouping rule.

**Schema:**
```sql
CREATE TABLE sessions (
    id INTEGER PRIMARY KEY,
    start_timestamp TEXT,
    end_timestamp TEXT,
    user_title TEXT,            -- nullable; user override, always wins if set
    auto_title TEXT,            -- "6/21/26 - Father's Day" style, generated
    markdown_raw_path TEXT,     -- transcript_raw.md, untouched concatenation
    markdown_refined_path TEXT, -- transcript.md, AI-sectioned version (nullable until refined)
    last_refined_at TEXT        -- nullable; null means never refined
);

CREATE TABLE audio_segments (
    id INTEGER PRIMARY KEY,
    session_id INTEGER REFERENCES sessions(id),
    timestamp TEXT,
    audio_path TEXT,
    raw_transcript TEXT,
    preceding_silence_seconds INTEGER,  -- gap before this segment; feeds AI sectioning
    source TEXT CHECK(source IN ('live', 'imported'))
);

CREATE VIRTUAL TABLE sessions_fts USING fts5(
    user_title, auto_title, markdown_content,
    content='sessions', content_rowid='id'
);
```

**Storage layout:** keep each session's audio and transcripts physically grouped on disk for easy backup/export:
```
journal_data/
└── session_2026-06-21_0930/
    ├── segment_001.wav
    ├── segment_002.wav
    ├── transcript_raw.md
    └── transcript.md
```

**Implementation Details:**
- `findOrCreateSession(timestamp)` — core grouping function, called after every segment is transcribed. See [Section 5](#session-grouping-logic).
- Insert/update segment rows, append to the session's `transcript_raw.md`.
- Full-text search via FTS5 across `user_title`, `auto_title`, and refined markdown content.
- **Storage Location:** platform-specific app data folders (e.g., `%LOCALAPPDATA%` on Windows, `~/.local/share` on Linux).

**Code Snippet (Conceptual C++):**
```cpp
// JournalDB.h
#include <sqlite3.h>
#include <string>
#include <vector>
#include <optional>
#include <memory>

struct Session {
    int id;
    std::string startTimestamp;
    std::string endTimestamp;
    std::optional<std::string> userTitle;
    std::string autoTitle;
    std::string markdownRawPath;
    std::optional<std::string> markdownRefinedPath;
};

class JournalDB {
public:
    JournalDB(const std::string& dbPath);
    ~JournalDB();
    bool open();
    void close();
    bool createTables();

    // Returns the session this segment belongs to, creating a new one
    // if more than 3 hours have passed since the last session's end_timestamp.
    Session findOrCreateSession(const std::string& segmentTimestamp);

    bool insertSegment(int sessionId, const std::string& audioPath,
                        const std::string& transcript, int precedingSilenceSeconds,
                        const std::string& source);

    bool setUserTitle(int sessionId, const std::string& title);
    std::vector<Session> searchSessions(const std::string& query);
    std::vector<Session> getAllSessions();
    std::vector<Session> getSessionsNeedingRefinement(); // raw newer than refined, or never refined

private:
    sqlite3* db;
    std::string dbFilePath;
};
```

### Module 5: User Interface (UI)

**Purpose:** Provide a simple interface for recording, importing, viewing, labeling, and searching journal entries.

**Libraries:** `Dear ImGui`.

**Implementation Details:**
- "Record" / "Stop" buttons for live capture.
- "Import Audio" button → file picker → `AudioImporter`.
- List of sessions (using `auto_title`, or `user_title` if set), most recent first.
- Inline title editing per session (sets `user_title`).
- Search input + results list.
- **Settings panel:** a field for the AI refinement endpoint URL (and auth token, if needed), persisted to a local `config.json` in the app data folder. Read by the AI Refiner module at refinement time — never hardcoded.
- A refinement status indicator per session (e.g., "Refined", "Pending", "Refinement failed — endpoint unreachable").

**Code Snippet (Conceptual C++ with ImGui):**
```cpp
// main.cpp (UI loop, partial)
void renderSettingsPanel(AppConfig& config) {
    ImGui::Begin("Settings");
    static char endpointBuffer[256];
    strncpy(endpointBuffer, config.aiEndpoint.c_str(), sizeof(endpointBuffer));
    if (ImGui::InputText("AI Refiner Endpoint", endpointBuffer, sizeof(endpointBuffer))) {
        config.aiEndpoint = endpointBuffer;
        config.save();
    }
    ImGui::End();
}

void renderUI(AudioRecorder& recorder, AudioImporter& importer,
              JournalDB& db, WhisperTranscriber& transcriber) {
    ImGui::Begin("Local Speech Journal");

    if (ImGui::Button("Start Recording")) recorder.startRecording();
    ImGui::SameLine();
    if (ImGui::Button("Stop Recording")) recorder.stopRecording();
    ImGui::SameLine();
    if (ImGui::Button("Import Audio")) {
        // open file picker, pass result to importer.importFile(...)
    }

    static char searchBuffer[256] = "";
    ImGui::InputText("Search", searchBuffer, sizeof(searchBuffer));
    ImGui::SameLine();
    if (ImGui::Button("Search")) {
        // db.searchSessions(searchBuffer)
    }

    ImGui::Separator();
    ImGui::Text("Journal Sessions:");
    // for each session: display title (editable), date range, refinement status

    ImGui::End();
}
```

### Module 6: AI Refiner (Remote)

**Purpose:** Periodically rewrite a session's raw transcript into a well-structured Markdown document, organized into sections by topic and by long pauses in the recording.

**Why remote:** Running a capable enough model for good-quality rewriting locally on a laptop is heavy. Offloading this to a personal server already optimized for inference is a reasonable privacy/performance tradeoff — only already-transcribed text for a given session is sent, never raw audio, and only to an endpoint you configure and control.

**Server side (already set up):** a `llama-server` (llama.cpp) instance, reachable on your network, accepting an Anthropic-style `/v1/messages` request body.

**Implementation Details:**
- `RefinerClient` reads the endpoint URL (and optional auth token) from `config.json`.
- Builds a request containing the session's segments — each with its text and `preceding_silence_seconds` — and a system prompt instructing the model to:
  - Group content into `##` sections by topic.
  - Treat unusually long pauses as likely section breaks.
  - Suggest a short topic phrase usable for the auto-title.
- Writes the result to `transcript_refined.md`, sets `markdown_refined_path` and `last_refined_at` in the DB, and never touches `transcript_raw.md` or `user_title`.
- Uses `libcurl` for the HTTP call; wrap in try/catch and handle endpoint-unreachable gracefully (mark session as "refinement failed," retry next cycle) — your laptop may try to refine while not on the same network as the server.

**Scheduling:** no need for a true overnight cron job — simplest robust approach is an **on-launch catch-up check**:
- On app startup, call `db.getSessionsNeedingRefinement()` (sessions where `transcript_raw.md` is newer than `transcript_refined.md`, or never refined, and the session is "closed" — i.e., more than 3 hours have passed since `end_timestamp`, so we're not refining a session still being actively recorded into).
- Queue those for background refinement one at a time, so it naturally happens whenever you next open the app with the AI server reachable.

**Code Snippet (Conceptual C++):**
```cpp
// RefinerClient.h
#include <string>
#include <optional>

struct RefinementResult {
    std::string refinedMarkdown;
    std::optional<std::string> suggestedTitle;
};

class RefinerClient {
public:
    RefinerClient(std::string endpointUrl, std::optional<std::string> authToken);

    // Returns std::nullopt on network failure / unreachable endpoint —
    // caller should mark the session as pending and retry later, not crash.
    std::optional<RefinementResult> refineSession(const std::string& rawMarkdown);

private:
    std::string endpoint;
    std::optional<std::string> token;
};
```

## 5. Session Grouping Logic

A **session** is the unit shown to the user as one journal entry. Segments (live or imported) are grouped into the same session if they fall within **3 hours** of the previous segment's end time:

1. New segment finishes transcribing with timestamp `T`.
2. `findOrCreateSession(T)` looks up the most recent session's `end_timestamp`.
3. If `T - end_timestamp <= 3 hours`: append to that session — update `end_timestamp`, append text to `transcript_raw.md`, insert the new `audio_segments` row with that `session_id`.
4. Otherwise: create a new session row, new folder (`session_<date>_<time>/`), and start a fresh `transcript_raw.md`.

This applies identically to imported audio — if you import a file timestamped within 3 hours of an existing session, it's folded into that session rather than creating a duplicate.

## 6. Titling

- **`auto_title`** — generated immediately on session creation: `<date> - <first few words of first segment's transcript>` (e.g., `6/21/26 - Father's Day`). Simple heuristic: first sentence, or first N words, truncated. Updated only if the AI Refiner later suggests a better topic phrase.
- **`user_title`** — set via the UI, always nullable, always takes display priority over `auto_title` when present. The AI Refiner never overwrites this.

## 7. Integration & Workflow

1. **Application Start:**
   - Initialize `PortAudio`, `libfvad`, `whisper.cpp` context, `SQLite` database.
   - Load Whisper model and `AppConfig` (including AI endpoint URL).
   - Run refinement catch-up check ([Module 6](#module-6-ai-refiner-remote)).
   - Open the UI window.
2. **Recording or Import:**
   - Live: `AudioRecorder` → `VoiceActivityDetector` → segment finalized on sustained silence.
   - Import: `AudioImporter` decodes file → VAD run over full file to find pause boundaries → segmented the same way.
   - Each finalized segment → `WhisperTranscriber` → raw text.
3. **Session Assignment:**
   - `JournalDB.findOrCreateSession(timestamp)` decides whether this segment joins an existing session or starts a new one.
   - Segment + transcript stored; `transcript_raw.md` updated; `auto_title` generated if this is a new session.
4. **User Interaction (UI):**
   - Browse/search sessions, edit `user_title`, play audio, view raw or refined transcript.
   - Background thread handles transcription and refinement so the UI stays responsive (see note on threading below).
5. **Refinement (background, async):**
   - For each session needing refinement: `RefinerClient.refineSession()` → write `transcript_refined.md` → update DB.

## 8. Build & Setup

```bash
# Clone and build whisper.cpp
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
cmake -B build
cmake --build build -j --config Release
./models/download-ggml-model.sh base.en

# Clone and build libfvad
git clone https://github.com/dpirch/libfvad.git
cd libfvad
mkdir build && cd build
cmake ..
make

# Audio I/O and import decoding
# Ubuntu/Debian:
sudo apt-get install libportaudio2 libportaudiocpp0 portaudio19-dev libsndfile1-dev
# macOS:
brew install portaudio libsndfile
# Windows: use vcpkg for portaudio / libsndfile.

# SQLite3
sudo apt-get install sqlite3 libsqlite3-dev   # Ubuntu/Debian
brew install sqlite3                          # macOS

# HTTP client for the AI Refiner
sudo apt-get install libcurl4-openssl-dev     # Ubuntu/Debian
brew install curl                             # macOS

# Dear ImGui (submodule)
git submodule add https://github.com/ocornut/imgui.git extern/imgui

# AI server (separate machine — not built here):
# Run llama-server from llama.cpp on your private server, pointed at a model
# of your choice. Note its address (e.g. http://192.168.1.50:8080) for the
# app's Settings panel.

# Compile the project
mkdir build && cd build
cmake ..
cmake --build .

# Run the application
./journal_app
```

**Example project structure:**
```
my_journal_app/
├── CMakeLists.txt
├── main.cpp
├── AudioRecorder.h / .cpp
├── AudioImporter.h / .cpp
├── VoiceActivityDetector.h / .cpp
├── WhisperTranscriber.h / .cpp
├── JournalDB.h / .cpp
├── RefinerClient.h / .cpp
├── AppConfig.h / .cpp        # loads/saves config.json (AI endpoint, etc.)
└── extern/
    ├── imgui/
    ├── whisper.cpp/
    └── libfvad/
```

## 9. A Note for C → C++ Learners

This project is a good fit for moving from C to C++ since most of it is "wrap a C library in a thin C++ class," not deep template metaprogramming. A couple of suggestions to keep the learning curve manageable:

- **Resource ownership:** instead of hand-writing destructors for every class wrapping a C handle (`PaStream*`, `sqlite3*`, `whisper_context*`), use `std::unique_ptr` with a custom deleter. It's a small concept, and it pays off immediately since this project wraps C APIs everywhere.
- **Threading last:** background transcription/refinement (`std::thread`, mutexes) is the sharpest edge here for someone new to C++. Build the pipeline single-threaded and blocking first — record/import → transcribe → save — and confirm it all works end to end before adding async behavior.

## 10. Future Enhancements

- Switch audio storage from WAV to FLAC if disk usage becomes a concern (lossless, ~40-60% smaller, same `libsndfile` dependency already in use for import).
- When the storage format is switched (WAV → FLAC, or vice versa), convert imported audio tracks to match the chosen format on import, rather than storing them in their original format — keeps all audio in the journal consistent regardless of source. Since imports are restricted to WAV/FLAC, this conversion only ever needs to handle one direction (WAV→FLAC or FLAC→WAV) via `libsndfile`, no new dependency needed.
- Manual session merge/split in the UI, in case the 3-hour rule doesn't match a particular day.
- Export a session (audio + markdown) as a single archive for backup.
- Local fallback model for refinement when the remote AI server is unreachable for extended periods.