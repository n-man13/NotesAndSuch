#include <iostream>
#include <vector>
#include "JournalDB.hpp"
#include "VoiceActivityDetector.hpp"
#include "whisper.h"

// Conceptual Audio Processing Loop
void runJournalingLoop(JournalDB& db, whisper_context* whisperCtx) {
    VoiceActivityDetector vad(16000);
    std::vector<int16_t> recordingBuffer;
    bool sessionActive = false;
    int silenceFrames = 0;

    std::cout << "Listening... (Talk to record, stop talking for 2s to save)" << std::endl;

    while (true) {
        // 1. Get 20ms of audio from PortAudio (320 samples)
        std::vector<int16_t> frame = { /* get_from_portaudio() */ };
        if (frame.empty()) break; 

        bool speech = vad.isSpeaking(frame.data(), frame.size());

        if (speech) {
            if (!sessionActive) {
                std::cout << "Speech detected. Recording started..." << std::endl;
                sessionActive = true;
            }
            recordingBuffer.insert(recordingBuffer.end(), frame.begin(), frame.end());
        } else if (sessionActive) {
            recordingBuffer.insert(recordingBuffer.end(), frame.begin(), frame.end());
            
            if (vad.shouldEndSegment(false, silenceFrames)) {
                std::cout << "Silence detected. Transcribing..." << std::endl;
                
                // 2. Convert int16 to float32 for Whisper
                std::vector<float> pcmf32(recordingBuffer.size());
                for (size_t i = 0; i < recordingBuffer.size(); ++i) {
                    pcmf32[i] = recordingBuffer[i] / 32768.0f;
                }

                // 3. Whisper Inference
                whisper_full_params wparams = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
                if (whisper_full(whisperCtx, wparams, pcmf32.data(), pcmf32.size()) == 0) {
                    std::string result = "";
                    int n_segments = whisper_full_n_segments(whisperCtx);
                    for (int i = 0; i < n_segments; ++i) {
                        result += whisper_full_get_segment_text(whisperCtx, i);
                    }

                    // 4. Save to Database
                    db.saveEntry("path/to/audio.wav", result);
                    std::cout << "Saved: " << result << std::endl;
                }

                recordingBuffer.clear();
                sessionActive = false;
            }
        }
    }
}

int main() {
    // Initialize DB
    JournalDB db("journal.db");
    if (!db.init()) return -1;

    // Initialize Whisper
    struct whisper_context_params cparams = whisper_context_default_params();
    whisper_context* ctx = whisper_init_from_file_with_params("models/ggml-base.en.bin", cparams);
    if (!ctx) return -1;

    runJournalingLoop(db, ctx);

    whisper_free(ctx);
    return 0;
}