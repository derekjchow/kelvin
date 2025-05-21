typedef unsigned int uint32_t;

const volatile uint32_t itcm_vec[] = {1, 2, 3, 4, 5, 6, 7, 8};
volatile uint32_t dtcm_vec[2048] __attribute__((section(".data")));
volatile uint32_t* extmem_vec = reinterpret_cast<uint32_t*>(0x20000000);
uint32_t halt = 0;

int main(int argc, char** argv) {
  for (int i = 0; i < 8; ++i) {
    extmem_vec[i] = i + 1;
  }
  uint32_t itcm_accum = 0;
  uint32_t dtcm_accum = 0;
  uint32_t extmem_accum = 0;
  while (!halt) {
    for (int i = 0; i < 8; ++i) {
      itcm_accum += itcm_vec[i];
      dtcm_accum += dtcm_vec[i];
      extmem_accum += extmem_vec[i];
      extmem_vec[i]++;
    }
  }
  return itcm_accum + dtcm_accum + extmem_accum;
}
