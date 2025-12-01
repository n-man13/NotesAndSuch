#include <stdio.h>
#include "timer.h"

void timer_init(SubathonTimer *timer, int start_seconds) {
    timer->remaining_seconds = start_seconds;
}

void timer_tick(SubathonTimer *timer) {
    if (timer->remaining_seconds > 0) {
        timer->remaining_seconds--;
    }
}

void timer_add(SubathonTimer *timer, int seconds) {
    timer->remaining_seconds += seconds;
}

void timer_get_string(SubathonTimer *timer, char *buffer, size_t buffer_size) {
    if (timer->remaining_seconds <= 0) {
        snprintf(buffer, buffer_size, "00:00:00");
        return;
    }

    int hours = timer->remaining_seconds / 3600;
    int minutes = (timer->remaining_seconds % 3600) / 60;
    int seconds = timer->remaining_seconds % 60;

    snprintf(buffer, buffer_size, "%02d:%02d:%02d", hours, minutes, seconds);
}
