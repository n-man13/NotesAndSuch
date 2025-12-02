#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "config.h"

int load_config(const char *filename, Config *config) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Failed to open config file");
        return 0;
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        // Skip comments and empty lines
        if (line[0] == '#' || line[0] == '\n' || line[0] == '\r') continue;

        char key[64], value[128];
        if (sscanf(line, "%63[^=]=%127s", key, value) == 2) {
            // Remove potential newline from value
            value[strcspn(value, "\r\n")] = 0;

            if (strcmp(key, "OAUTH_TOKEN") == 0) {
                strncpy(config->oauth_token, value, sizeof(config->oauth_token) - 1);
            } else if (strcmp(key, "BOT_USERNAME") == 0) {
                strncpy(config->bot_username, value, sizeof(config->bot_username) - 1);
            } else if (strcmp(key, "CHANNEL") == 0) {
                strncpy(config->channel, value, sizeof(config->channel) - 1);
            } else if (strcmp(key, "MIN_SECONDS_ADD") == 0) {
                config->min_seconds_add = atoi(value);
            } else if (strcmp(key, "MAX_SECONDS_ADD") == 0) {
                config->max_seconds_add = atoi(value);
            } else if (strcmp(key, "INITIAL_MINUTES") == 0) {
                config->initial_time = atoi(value) * 60; // Convert to seconds
            } else if (strcmp(key, "REWARD_ID") == 0) {
                strncpy(config->reward_id, value, sizeof(config->reward_id) - 1);
            } else if (strcmp(key, "MIN_SECONDS_REDEEM") == 0) {
                config->min_seconds_redeem = atoi(value);
            } else if (strcmp(key, "MAX_SECONDS_REDEEM") == 0) {
                config->max_seconds_redeem = atoi(value);
            }
        }
    }

    fclose(file);
    return 1;
}
