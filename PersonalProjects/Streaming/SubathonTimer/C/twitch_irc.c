#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>
#include "twitch_irc.h"

#define TWITCH_HOST "irc.chat.twitch.tv"
#define TWITCH_PORT 6697

int twitch_connect(TwitchConnection *conn) {
    struct hostent *host;
    struct sockaddr_in addr;

    SSL_library_init();
    OpenSSL_add_all_algorithms();
    SSL_load_error_strings();
    
    conn->ctx = SSL_CTX_new(TLS_client_method());
    if (conn->ctx == NULL) {
        ERR_print_errors_fp(stderr);
        return 0;
    }

    host = gethostbyname(TWITCH_HOST);
    if (host == NULL) {
        perror("Unknown host");
        return 0;
    }

    conn->socket = socket(AF_INET, SOCK_STREAM, 0);
    if (conn->socket < 0) {
        perror("Socket creation failed");
        return 0;
    }

    addr.sin_family = AF_INET;
    addr.sin_port = htons(TWITCH_PORT);
    addr.sin_addr = *((struct in_addr *)host->h_addr);

    if (connect(conn->socket, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        perror("Connection failed");
        close(conn->socket);
        return 0;
    }

    conn->ssl = SSL_new(conn->ctx);
    SSL_set_fd(conn->ssl, conn->socket);

    if (SSL_connect(conn->ssl) == -1) {
        ERR_print_errors_fp(stderr);
        close(conn->socket);
        return 0;
    }

    // Set non-blocking mode after connection for the loop
    int flags = fcntl(conn->socket, F_GETFL, 0);
    fcntl(conn->socket, F_SETFL, flags | O_NONBLOCK);

    conn->connected = 1;
    printf("Connected to Twitch IRC (SSL)\n");
    return 1;
}

int twitch_authenticate(TwitchConnection *conn, const char *token, const char *username, const char *channel) {
    char buffer[512];
    
    snprintf(buffer, sizeof(buffer), "PASS %s\r\n", token);
    SSL_write(conn->ssl, buffer, strlen(buffer));
    
    snprintf(buffer, sizeof(buffer), "NICK %s\r\n", username);
    SSL_write(conn->ssl, buffer, strlen(buffer));

    // Request capabilities (tags) to see subs
    const char *cap_req = "CAP REQ :twitch.tv/tags twitch.tv/commands\r\n";
    SSL_write(conn->ssl, cap_req, strlen(cap_req));

    snprintf(buffer, sizeof(buffer), "JOIN #%s\r\n", channel);
    SSL_write(conn->ssl, buffer, strlen(buffer));
    
    printf("Authenticated and joined #%s\n", channel);
    return 1;
}

int twitch_read(TwitchConnection *conn, char *buffer, int size) {
    if (!conn->connected) return -1;
    int bytes = SSL_read(conn->ssl, buffer, size - 1);
    if (bytes > 0) {
        buffer[bytes] = '\0';
    }
    return bytes;
}

void twitch_send_pong(TwitchConnection *conn) {
    const char *pong = "PONG :tmi.twitch.tv\r\n";
    SSL_write(conn->ssl, pong, strlen(pong));
    printf("Sent PONG\n");
}

void twitch_disconnect(TwitchConnection *conn) {
    if (conn->ssl) {
        SSL_shutdown(conn->ssl);
        SSL_free(conn->ssl);
    }
    if (conn->socket) {
        close(conn->socket);
    }
    if (conn->ctx) {
        SSL_CTX_free(conn->ctx);
    }
    conn->connected = 0;
}
