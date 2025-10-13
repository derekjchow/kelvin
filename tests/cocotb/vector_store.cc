// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <riscv_vector.h>
int main(int argc, char** argv) {
    vuint8m1_t vec = __riscv_vid_v_u8m1(16);
    unsigned char* storage = reinterpret_cast<unsigned char*>(0xa0000000);
    __riscv_vse8_v_u8m1(storage, vec, 16);
    return 0;
}
