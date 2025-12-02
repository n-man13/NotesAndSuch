#ifndef CONFIG_H
#define CONFIG_H

typedef struct {
    char oauth_token[128];
    char bot_username[64];
    char channel[64];
    int min_seconds_add;
    int max_seconds_add;
    int initial_time; // Stored in seconds internally
    
    // Redeem Config
    char reward_id[64];
    int min_seconds_redeem;
    int max_seconds_redeem;
} Config;

// Loads configuration from config.txt
// Returns 1 on success, 0 on failure
int load_config(const char *filename, Config *config);

#endif
