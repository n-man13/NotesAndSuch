#ifndef TIMER_H
#define TIMER_H

typedef struct {
    long long remaining_seconds;
} SubathonTimer;

void timer_init(SubathonTimer *timer, int start_seconds);
void timer_tick(SubathonTimer *timer);
void timer_add(SubathonTimer *timer, int seconds);
void timer_get_string(SubathonTimer *timer, char *buffer, size_t buffer_size);

#endif
