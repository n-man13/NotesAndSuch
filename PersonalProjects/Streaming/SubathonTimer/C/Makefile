CC = gcc
CFLAGS = -Wall -Wextra -g
LIBS = -lssl -lcrypto

# Determine OS for linking
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	LIBS += -lpthread -ldl
endif

SRC = main.c config.c timer.c file_io.c twitch_irc.c
OBJ = $(SRC:.c=.o)
TARGET = subathon_timer

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ) $(LIBS)

clean:
	rm -f $(OBJ) $(TARGET)

.PHONY: all clean
