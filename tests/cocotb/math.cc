#pragma GCC optimize("O0")

int math(int a, int b) {
    return ((2 * a) + (3 * b * b));
}

int main(int argc, char** argv) {
    int sum = 0;
    for (int i = 0, j = 0; i < 2; ++i, ++j) {
        sum += math(i, j);
    }
    return (sum == 5) ? 0 : 1;
}