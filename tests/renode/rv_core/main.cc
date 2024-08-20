#include "kelvin_hello_world_cc.h"
#include <cstdint>

uint32_t* uart0 = (uint32_t*)0x54000000L;
void putc(char ch) {
    *uart0 = ch;
}

char hex[] = {
    '0', '1', '2', '3',
    '4', '5', '6', '7',
    '8', '9', 'a', 'b',
    'c', 'd', 'e', 'f',
};
void print_uint32(uint32_t val) {
    putc('0');
    putc('x');
    for (int i = 7; i >= 0; --i) {
        putc(hex[(val >> (i * 4)) & 0xF]);
    }
    putc('\n');
}

void print_string(const char* s) {
    while (*s) {
        putc(*s++);
    }
}

void main(void) {
    uint8_t* kelvin_itcm = (uint8_t*)0x70000000L;
    for (int i = 0; i < kelvin_hello_world_cc_bin_len; ++i) {
        kelvin_itcm[i] = kelvin_hello_world_cc_bin[i];
    }
    uint32_t* kelvin_reset_csr = (uint32_t*)0x70002000L;
    // Disable clock gate
    *kelvin_reset_csr = 1;

    // Tick a few cycles to allow Kelvin to reset.
    for (volatile int i = 0; i < 10; ++i) {
        asm volatile("nop");
    }

    // Release reset
    *kelvin_reset_csr = 0;

    uint32_t* kelvin_status_csr = (uint32_t*)0x70002008L;
    while (true) {
        uint32_t status = *kelvin_status_csr;
        if ((status & 3) == 3) {
            print_string("FAIL\n");
            break;
        } else if ((status & 1) == 1) {
            print_string("PASS\n");
            break;
        }
    }

    uint32_t* kelvin_csrs = (uint32_t*)0x70002100L;
    for (int i = 0; i < 8; ++i) {
        print_uint32(*(kelvin_csrs + i));
    }

    *kelvin_reset_csr = 3;
    while (true) {
        asm volatile("wfi");
    }
}
