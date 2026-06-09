#pragma once
#include <fvad.h>
#include <vector>
#include <cstdint>

class VoiceActivityDetector {
public:
    VoiceActivityDetector(int sampleRate = 16000) {
        vad = fvad_new();
        fvad_set_sample_rate(vad, sampleRate);
        // Mode 2 is a good balance between sensitivity and noise
        fvad_set_mode(vad, 2); 
    }

    ~VoiceActivityDetector() {
        if (vad) fvad_free(vad);
    }

    // Processes a frame (usually 20ms or 320 samples at 16kHz)
    bool isSpeaking(const int16_t* samples, size_t count) {
        int result = fvad_process(vad, samples, count);
        return result == 1;
    }

    // Logic to decide if we should stop recording a segment
    bool shouldEndSegment(bool frameHasSpeech, int& silenceFrames, int threshold = 100) {
        if (frameHasSpeech) {
            silenceFrames = 0;
            return false;
        } else {
            silenceFrames++;
            return silenceFrames >= threshold; // 100 frames * 20ms = 2 seconds
        }
    }

private:
    Fvad* vad;
};