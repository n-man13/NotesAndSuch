CXX = g++
CXXFLAGS = -std=c++11 -Wall -O3 -pthread

# External library paths (adjust if your directory structure differs)
WHISPER_PATH = ./extern/whisper.cpp
FVAD_PATH = ./extern/libfvad

# Include directories
# We include the current directory for JournalDB.hpp and VoiceActivityDetector.hpp
INCLUDES = -I. \
           -I$(WHISPER_PATH) \
           -I$(FVAD_PATH)/include

# Linker flags and libraries
# libwhisper.a is usually created in the whisper.cpp root after running 'make' there.
# libfvad.a is usually created in the build directory after building it.
LDFLAGS = -L$(WHISPER_PATH) \
          -L$(FVAD_PATH)/build

# Libraries to link against
# -lwhisper: whisper.cpp core
# -lfvad: libfvad core
# -lportaudio: PortAudio for microphone access
# -lsqlite3: SQLite3 for data storage
LIBS = -lwhisper -lfvad -lportaudio -lsqlite3 -lpthread -ldl

TARGET = journal_app
SRCS = main.cpp
OBJS = $(SRCS:.cpp=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $@ $^ $(LDFLAGS) $(LIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
