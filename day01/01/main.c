#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>

#define BUFFER_SIZE 2048

int main(void) {
    FILE* fp = fopen("../input.txt", "r");
    if (!fp) {
        fprintf(stderr, "Could not open input file\n");
        exit(1);
    }

    char buf[BUFFER_SIZE];
    int prev = INT_MAX;
    int increments = 0;
    while(fgets(buf, BUFFER_SIZE, fp)) {
        int value = atoi(buf);

        if (value > prev) {
            increments++;
#ifdef PRINT_STEPS
            fprintf(stdout, "%d +++ %d\n", value, increments);
        } else {
            fprintf(stdout, "%d\n", value);
#endif
        }

        prev = value;
    }

    fprintf(stdout, "Result: %d\n", increments);
    fclose(fp);
    fflush(0);
    return 0;
}
