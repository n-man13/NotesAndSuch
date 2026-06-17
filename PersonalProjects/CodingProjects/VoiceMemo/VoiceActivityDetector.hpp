#pragma once

#include <fvad.h>
#include <vector>
#include <cstdint>

class VoiceActivityDetector {
public:
    VoiceActivityDetector(int sampleRate) : sampleRate(sampleRate) {
        vad = fvad_new();
        fvad_set_sample_rate(vad, sampleRate);
        // Mode 3 is the most aggressive/least tolerant of noise
        fvad_set_mode(vad, 3);
    }

    ~VoiceActivityDetector() {
        if (vad) fvad_free(vad);
    }

    /**
     * Checks if a frame contains speech.
     * Note: libfvad expects 10ms, 20ms, or 30ms frames of 16-bit PCM.
     */
    bool isSpeaking(const int16_t* samples, size_t numSamples) {
        int result = fvad_process(vad, samples, numSamples);
        return result == 1;
    }

    /**
     * Simple logic to determine if a recording segment should end.
     * Usually based on a streak of silence frames.
     */
    bool shouldEndSegment(bool currentFrameIsSpeech, int& silenceFramesCounter) {
        if (currentFrameIsSpeech) {
            silenceFramesCounter = 0;
            return false;
        } else {
            silenceFramesCounter++;
            // If sampleRate is 16000 and we process 20ms frames (320 samples),
            // 100 frames = 2 seconds of silence.
            const int SILENCE_THRESHOLD = 100; 
            return silenceFramesCounter >= SILENCE_THRESHOLD;
        }
    }

private:
    Fvad* vad;
    int sampleRate;
};