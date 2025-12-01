#ifndef TWITCH_IRC_H
#define TWITCH_IRC_H

#include <openssl/ssl.h>
#include <openssl/err.h>

typedef struct {
    int socket;
    SSL_CTX *ctx;
    SSL *ssl;
    int connected;
} TwitchConnection;

int twitch_connect(TwitchConnection *conn);
void twitch_disconnect(TwitchConnection *conn);
int twitch_authenticate(TwitchConnection *conn, const char *token, const char *username, const char *channel);
// Returns number of bytes read, or <= 0 on error/disconnect
int twitch_read(TwitchConnection *conn, char *buffer, int size);
void twitch_send_pong(TwitchConnection *conn);

#endif
