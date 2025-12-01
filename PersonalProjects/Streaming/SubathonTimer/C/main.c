#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include "config.h"
#include "timer.h"
#include "file_io.h"
#include "twitch_irc.h"

#define BUFFER_SIZE 4096
#define TIMER_FILE "timer.txt"

int main() {
    Config config;
    SubathonTimer timer;
    TwitchConnection twitch_conn;
    char recv_buffer[BUFFER_SIZE];
    char time_str[64];
    time_t last_tick_time = time(NULL);

    // Seed random number generator
    srand(time(NULL));

    // 1. Load Config
    if (!load_config("config.txt", &config)) {
        fprintf(stderr, "Error: Could not load config.txt\n");
        return 1;
    }

    // 2. Initialize Timer (config.initial_time is already in seconds)
    timer_init(&timer, config.initial_time);
    printf("Timer started at %d seconds (%d minutes).\n", config.initial_time, config.initial_time / 60);

    // 3. Connect to Twitch
    if (!twitch_connect(&twitch_conn)) {
        fprintf(stderr, "Error: Could not connect to Twitch.\n");
        return 1;
    }

    if (!twitch_authenticate(&twitch_conn, config.oauth_token, config.bot_username, config.channel)) {
        fprintf(stderr, "Error: Could not authenticate.\n");
        twitch_disconnect(&twitch_conn);
        return 1;
    }

    printf("Subathon Timer Running... Press Ctrl+C to stop.\n");

    // 4. Main Loop
    while (1) {
        // --- Handle Twitch Messages ---
        int bytes_read = twitch_read(&twitch_conn, recv_buffer, BUFFER_SIZE);
        if (bytes_read > 0) {
            // Simple parsing (line by line)
            char *line = strtok(recv_buffer, "\r\n");
            while (line != NULL) {
                // Keep connection alive
                if (strstr(line, "PING :tmi.twitch.tv")) {
                    twitch_send_pong(&twitch_conn);
                } 
                // Check for Subscriptions (USERNOTICE with msg-id=sub, resub, subgift, etc.)
                else if (strstr(line, "USERNOTICE") && 
                        (strstr(line, "msg-id=sub") || strstr(line, "msg-id=resub") || strstr(line, "msg-id=subgift"))) {
                    
                    // Calculate random add amount
                    int range = config.max_seconds_add - config.min_seconds_add;
                    int added_seconds = config.min_seconds_add;
                    if (range > 0) {
                        added_seconds += rand() % (range + 1);
                    }
                    
                    printf("Subscription detected! Adding %d seconds.\n", added_seconds);
                    timer_add(&timer, added_seconds);
                }
                // Check for Channel Point Redemptions
                // Look for 'custom-reward-id=UUID' in tags
                else if (strlen(config.reward_id) > 0 && strstr(line, "custom-reward-id=") && strstr(line, config.reward_id)) {
                     // Calculate random add amount for redeem
                    int range = config.max_seconds_redeem - config.min_seconds_redeem;
                    int added_seconds = config.min_seconds_redeem;
                    if (range > 0) {
                        added_seconds += rand() % (range + 1);
                    }

                    printf("Redemption detected! Adding %d seconds.\n", added_seconds);
                    timer_add(&timer, added_seconds);
                }

                line = strtok(NULL, "\r\n");
            }
        }

        // --- Handle Timer Tick ---
        time_t current_time = time(NULL);
        if (current_time > last_tick_time) {
            timer_tick(&timer);
            last_tick_time = current_time;
            
            // --- Update File ---
            timer_get_string(&timer, time_str, sizeof(time_str));
            write_timer_to_file(TIMER_FILE, time_str);
            
            // Optional: Print to console every now and then or just debug
            // printf("\r%s", time_str);
            // fflush(stdout);
        }

        // Sleep to prevent high CPU usage
        usleep(100000); // 100ms
    }

    twitch_disconnect(&twitch_conn);
    return 0;
}
