#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#define INPUT "input.txt"
#define DIGIT_LAYER_COUNT 7
#define DIGIT_CHAR_COUNT 6

#define NUM_0_BCOUNT 6
#define NUM_1_BCOUNT 2
#define NUM_2_BCOUNT 5
#define NUM_3_BCOUNT 5
#define NUM_4_BCOUNT 4
#define NUM_5_BCOUNT 5
#define NUM_6_BCOUNT 6
#define NUM_7_BCOUNT 3
#define NUM_8_BCOUNT 7
#define NUM_9_BCOUNT 6

typedef enum {
    SIG_A = 0b00000001,
    SIG_B = 0b00000010,
    SIG_C = 0b00000100,
    SIG_D = 0b00001000,
    SIG_E = 0b00010000,
    SIG_F = 0b00100000,
    SIG_G = 0b01000000,
} SignalEnum;

typedef enum {
    DIGIT_0 = SIG_A | SIG_B | SIG_C | SIG_E | SIG_F | SIG_G,
    DIGIT_1 = SIG_C | SIG_F,
    DIGIT_2 = SIG_A | SIG_C | SIG_D | SIG_E | SIG_G,
    DIGIT_3 = SIG_A | SIG_C | SIG_D | SIG_F | SIG_G,
    DIGIT_4 = SIG_B | SIG_C | SIG_D | SIG_F,
    DIGIT_5 = SIG_A | SIG_B | SIG_D | SIG_F | SIG_G,
    DIGIT_6 = SIG_A | SIG_B | SIG_D | SIG_E | SIG_F | SIG_G,
    DIGIT_7 = SIG_A | SIG_C | SIG_F,
    DIGIT_8 = SIG_A | SIG_B | SIG_C | SIG_D | SIG_E | SIG_F | SIG_G,
    DIGIT_9 = SIG_A | SIG_B | SIG_C | SIG_D | SIG_F | SIG_G,
} DigitEnum;

const static unsigned char DIGIT_LAYERS[DIGIT_LAYER_COUNT][DIGIT_CHAR_COUNT] = {
    {0, SIG_A, SIG_A, SIG_A, SIG_A, 0},
    {SIG_B, 0, 0, 0, 0, SIG_C},
    {SIG_B, 0, 0, 0, 0, SIG_C},
    {0, SIG_D, SIG_D, SIG_D, SIG_D, 0},
    {SIG_E, 0, 0, 0, 0, SIG_F},
    {SIG_E, 0, 0, 0, 0, SIG_F},
    {0, SIG_G, SIG_G, SIG_G, SIG_G, 0},
};

static inline
char get_digit_char(char a) {
    switch (a) {
        case DIGIT_1: return '1';
        case DIGIT_2: return '2';
        case DIGIT_3: return '3';
        case DIGIT_4: return '4';
        case DIGIT_5: return '5';
        case DIGIT_6: return '6';
        case DIGIT_7: return '7';
        case DIGIT_8: return '8';
        case DIGIT_9: return '9';
        default: return '0';
    }
}

static inline
int count_set_bits(unsigned char a) {
    int i = 0;
    for (; a; i++) {
        a &= a - 1;
    }
    return i;
}

static inline
int get_bit_idx(unsigned char a) {
    for (int i = 0; i < 8; i++) {
        if ((a & (1 << i)) > 0) return i;
    }
    return -1;
}

static
unsigned char create_sig_map(unsigned char* input, int input_len, unsigned char* map_ptr) {
    unsigned char sigc_map[7] = {0};
    int num1_idx = 0;
    int num4_idx = 0;
    int num7_idx = 0;
    int num8_idx = 0;

    for (int i = 0; i < input_len; i++) {
        int bitc = 0;
        for (int b = 0; b < 7; b++) {
            if ((input[i] & (1 << b)) > 0) {
                sigc_map[b]++;
                bitc++;
            }
        }

        if (bitc == NUM_1_BCOUNT)
            num1_idx = i;
        else if (bitc == NUM_4_BCOUNT)
            num4_idx = i;
        else if (bitc == NUM_7_BCOUNT)
            num7_idx = i;
        else if (bitc == NUM_8_BCOUNT)
            num8_idx = i;
    }

    unsigned char sig_a = input[num7_idx] ^ input[num1_idx];
    unsigned char sig_b = 0;
    unsigned char sig_c = 0;
    unsigned char sig_d = 0;
    unsigned char sig_e = 0;
    unsigned char sig_f = 0;
    unsigned char sig_g = 0;

    for (unsigned char i = 0; i < 7; i++) {
        switch (sigc_map[i]) {
            case 4: // E
                sig_e = (1 << i);
                map_ptr[4] = i;
                break;
            case 6: // B
                sig_b = (1 << i);
                map_ptr[1] = i;
                break;
            case 9: // F
                sig_f = (1 << i);
                map_ptr[5] = i;
                break;
            default:
                break;
        }
    }

    sig_c = input[num1_idx] ^ sig_f;
    sig_d = input[num4_idx] ^ (input[num1_idx] | sig_b);
    sig_g = (input[num8_idx] ^ input[num4_idx]) & ~(sig_e | sig_a);

    // A signal
    map_ptr[0] = get_bit_idx(sig_a);
    // C signal
    map_ptr[2] = get_bit_idx(sig_c);
    // D signal
    map_ptr[3] = get_bit_idx(sig_d);
    // G signal
    map_ptr[6] = get_bit_idx(sig_g);
}

static
void map_sigs(int len, unsigned char* input_ptr, unsigned char* output_ptr, unsigned char* map_ptr) {
    unsigned char result = 0;
    for (int i = 0; i < len; i++) {
        for (int b = 0; b < 7; b++) {
            unsigned char idx = map_ptr[b];
            unsigned char val = (input_ptr[i] & (1 << idx)) >> idx;
            output_ptr[i] |= val << b;
        }
    }
}

static
void print_digits(unsigned char* input, int len) {
    for (int l = 0; l < DIGIT_LAYER_COUNT; l++) {
        for (int i = 0; i < len; i++) {
            for (int s = 0; s < DIGIT_CHAR_COUNT; s++) {
                unsigned char in = input[i];
                unsigned char mask = DIGIT_LAYERS[l][s];
                if (mask == 0 || (in & mask) < 1) {
                    printf(" ");
                } else {
                    printf("█");
                }
            }
            printf(" ");
        }
        printf("\n");
    }
}

int main(void) {
    FILE* file = fopen(INPUT, "r");
    if (!file) {
        perror("Cannot open file");
        exit(errno);
    }

    char buf[2048];

    long result = 0;
    while (fgets(&buf, 2048, file) != 0) {
        unsigned char sig_map[8] = {0};
        unsigned char enc_numbers[10] = {0};
        unsigned char enc_display[4] = {0};
        unsigned char dec_display[4] = {0};

        int rmode = 0;
        int i = 0;
        int cur = 0;
        char c = buf[i];
        while (c != '\n') {
            switch (c) {
                case '|': {
                    rmode++;
                    cur = -1;
                    break;
                }
                case ' ': {
                    cur++;
                    break;
                }
                default: {
                    unsigned char num = (unsigned char)(c - 'a');
                    if (rmode < 1) {
                        enc_numbers[cur] |= (1 << num);
                    } else {
                        enc_display[cur] |= (1 << num);
                    }
                    break;
                }
            }
            c = buf[++i];
        }

        create_sig_map(enc_numbers, 10, &sig_map);
        map_sigs(4, enc_display, dec_display, &sig_map);

        printf("ENCODED:\n");
        print_digits(enc_display, 4);
        printf("DECODED:\n");
        print_digits(dec_display, 4);

        char disp_chars[4] = "0000";
        for (int i = 0; i < 4; i++) {
            char c = get_digit_char((char)dec_display[i]);
            disp_chars[i] = c;
        }
        int disp_num = atoi(disp_chars);
        result += disp_num;

        printf("AS NUMBER: %d\n", disp_num);
        printf("=====================================\n");
    }

    fclose(file);

    printf("Result: %d\n", result);
    fflush(0);
    return 0;
}
