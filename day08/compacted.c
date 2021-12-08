#include <stdlib.h>
#include <stdio.h>

#define DIGITS_CNT 10
#define OUTPUT_CNT 4
#define INPUT_CNT DIGITS_CNT + OUTPUT_CNT

static inline char lookup_digit(int in) {
    switch(in) {
        case 0b01101111: return '9';
        case 0b01111111: return '8';
        case 0b00100101: return '7';
        case 0b01111011: return '6';
        case 0b01101011: return '5';
        case 0b00101110: return '4';
        case 0b01101101: return '3';
        case 0b01011101: return '2';
        case 0b00100100: return '1';
        default: return '0';
    }
}

static inline int get_bit_idx(unsigned char a) {
    for (int i = 0; i < 8; i++)
        if ((a & (1 << i)) > 0) return i;
    return -1;
}

int main(void) {
    long result = 0;
    FILE* file = fopen("input.txt", "r");
    char buf[2048];
    while (fgets(&buf, 2048, file) != 0) {
        int sig[7] = {0}; // Signals
        int sig_map[7] = {0}; // Bit-index map of signals occurred
        int in[INPUT_CNT] = {0}; // Digit as bitflagged num
        int significant[4] = {0}; // Digits 1, 4, 7, 8
        int in_sc = 0; // Input signal count per digit

        // Parse & extract information
        int i = 0; // Current letter
        int rmode = 0; // Reading patterns or display
        int num = 0; // Current digit
        int c = buf[i]; // Current character
        while (c != '\n') {
            switch (c) {
                case '|': {
                    // Map signals
                    for (int s = 0; s < 7; s++) {
                        if (sig_map[s] == 4)
                            sig[4] = 1 << s; // Signal E
                        else if (sig_map[s] == 6)
                            sig[1] = 1 << s; // Signal B
                        else if (sig_map[s] == 9)
                            sig[5] = 1 << s; // Signal F
                    }
                    sig[0] = significant[2] ^ significant[0]; // Signal A
                    sig[2] = significant[0] ^ sig[5]; // Signal C
                    sig[3] = significant[1] ^ (significant[0] | sig[1]); // Signal D
                    sig[6] = (significant[3] ^ significant[1]) & ~(sig[4] | sig[0]); // Signal G
                    num--;
                } break;
                case ' ': {
                    // Map numbers
                    if (rmode == 0) {
                        switch(in_sc) {
                            case 2: significant[0] = in[num]; break; // Digit 1
                            case 4: significant[1] = in[num]; break; // Digit 4
                            case 3: significant[2] = in[num]; break; // Digit 7
                            case 7: significant[3] = in[num]; break; // Digit 8
                            default: break;
                        }
                    }
                    in_sc = 0;
                    num++;
                } break;
                default: {
                    int pat_idx = c - 'a';
                    in[num] |= 1 << pat_idx;
                    in_sc++;
                    if (rmode == 0)
                        sig_map[pat_idx]++;
                } break;
            }
            c = buf[++i];
        }

        // Map scrambled bits to output
        char out[OUTPUT_CNT + 1] = {0};
        for (int i = 0; i < OUTPUT_CNT; i++) {
            int val = 0;
            for (int b = 0; b < 7; b++) {
                int idx = get_bit_idx(sig[b]);
                val |= ((in[10 + i] & (1 << idx)) >> idx) << b;
            }
            out[i] = lookup_digit(val);
        }
        result += atoi(out);

        printf("Output: %s\n", out);
    }

    fclose(file);
    printf("Result: %ld\n", result);
}
