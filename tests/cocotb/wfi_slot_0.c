int main(int argc, char** argv) {
    int ret_val;
    asm volatile("wfi");
    ret_val = *(&argc);
    return ret_val;
}
