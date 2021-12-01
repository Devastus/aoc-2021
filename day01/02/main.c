#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define BUFFER_SIZE 1024
#define NUM_ARR_SIZE 8192
#define SLIDING_WIN_RANGE 3
#define MEASURE_ITER 10000

static inline int
get_sliding_win_sum(int start, int end, int* num_ptr) {
    int result = 0;
    for (int i = start; i < end; i++) {
        result += num_ptr[i];
    }
    return result;
}

int a(void) {
    FILE* fp = fopen("../input.txt", "r");
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

    return increments;
}

int b(void) {
    FILE* fp = fopen("../input.txt", "r");
    if (!fp) {
        fprintf(stderr, "Could not open input file\n");
        exit(1);
    }

    char buf[BUFFER_SIZE];
    int win_a = 0;
    int win_b = 0;
    int tail = 0;
    int mid = 0;
    int head = 0;
    int prev_head = 0;
    int increments = 0;

    fgets(buf, BUFFER_SIZE, fp);
    tail = atoi(buf);
    win_a = tail;

    // Pre-fill Window A
    for (int i = 1; i < 3; i++) {
        fgets(buf, BUFFER_SIZE, fp);
        head = atoi(buf);
        win_a += head;
    }

    while(fgets(buf, BUFFER_SIZE, fp)) {
        prev_head = head;
        head = atoi(buf);
        mid = win_a - tail - prev_head;
        win_b = mid + prev_head + head;

        if (win_b > win_a) {
            increments++;
#ifdef PRINT_STEPS
            fprintf(stdout, "%d -> %d +++ %d\n", win_a, win_b, increments);
        } else {
            fprintf(stdout, "%d -> %d\n", win_a, win_b);
#endif
        }

        tail = mid;
        win_a = win_b;
    }

    fclose(fp);

    return increments;
}

int main(void) {
    int result = 0;

    // Measure entry A
    clock_t start = clock();
    for (int i = 0; i < MEASURE_ITER; i++) {
        result = a();
    }
    clock_t end = clock();
    double duration = (double)(end - start) / CLOCKS_PER_SEC;
    fprintf(stdout, "A) Result: %d, Time: %fsec\n", result, duration);

    // Measure entry B
    start = clock();
    for (int i = 0; i < MEASURE_ITER; i++) {
        result = b();
    }
    end = clock();
    duration = (double)(end - start) / CLOCKS_PER_SEC;
    fprintf(stdout, "B) Result: %d, Time: %fsec\n", result, duration);

    fflush(0);
    return 0;
}
