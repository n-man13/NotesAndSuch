#ifndef AUDIO_RECORDER_H
#define AUDIO_RECORDER_H

// #include <portaudio.h>
#include <vector>

class AudioRecorder {
private:
    paInt16 *buffer;
    UInt32 numSamples;
    paError error;
    bool isRecording;
    std::vector<float> audioData;
    unsigned int sampleRate;
    int inputDeviceID;

public:
    AudioRecorder(int deviceID = 0);
    ~AudioRecorder();

    void startRecording();
    void stopRecording();
    void addSamples(float sample);
    void addSamples(const float *samples, int numSamplesToAdd);
    void resetBuffer();
    std::vector<float> getAudioData();

    // Additional methods and member variables as needed
};

#endif //AUDIO_RECORDER_H