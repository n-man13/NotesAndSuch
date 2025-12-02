#include <stdio.h>
#include "file_io.h"

void write_timer_to_file(const char *filename, const char *time_str) {
    FILE *f = fopen(filename, "w");
    if (f) {
        fprintf(f, "%s", time_str);
        fclose(f);
    } else {
        // Only print error once to avoid spamming logs, or handle appropriately
        // perror("Failed to write timer file"); 
    }
}
