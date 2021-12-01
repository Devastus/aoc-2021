#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 2048
#define NUM_ARR_SIZE 8192
#define SLIDING_WIN_RANGE 3

static inline int
get_sliding_win_sum(int start, int end, int* num_ptr) {
    int result = 0;
    for (int i = start; i < end; i++) {
        result += num_ptr[i];
    }
    return result;
}

int main(void) {
    FILE* fp = fopen("input.txt", "r");
    if (!fp) {
        fprintf(stderr, "Could not open input file\n");
        exit(1);
    }

    // Pre-read inputs in for convenience
    int num_arr[NUM_ARR_SIZE] = {0};
    int num_arr_len = 0;
    {
        char buf[BUFFER_SIZE] = {0};
        while(fgets(buf, BUFFER_SIZE, fp)) {
            num_arr[num_arr_len] = atoi(buf);
            num_arr_len++;
        }
        fclose(fp);
    }

    int win_a = get_sliding_win_sum(0, SLIDING_WIN_RANGE, num_arr);
    int win_b = 0;
    int increments = 0;

    for (int i = SLIDING_WIN_RANGE + 1; i <= num_arr_len; i++) {
        win_b = get_sliding_win_sum(i - SLIDING_WIN_RANGE, i, num_arr);

        if (win_b > win_a) {
            increments++;
#ifdef PRINT_STEPS
            fprintf(stdout, "%d -> %d +++ %d\n", win_a, win_b, increments);
        } else {
            fprintf(stdout, "%d -> %d\n", win_a, win_b);
#endif
        }

        win_a = win_b;
    }

    fprintf(stdout, "Result: %d\n", increments);
    fflush(0);
    return 0;
}
