// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <math.h>
#include <stdint.h>
#include <stdio.h>

#include "tensorflow/lite/core/c/common.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/system_setup.h"
#include "tests/cocotb/tutorial/hello_world_tflite.h"

namespace {
using HelloWorldOpResolver = tflite::MicroMutableOpResolver<1>;

TfLiteStatus RegisterOps(HelloWorldOpResolver& op_resolver) {
  TF_LITE_ENSURE_STATUS(op_resolver.AddFullyConnected());
  return kTfLiteOk;
}
}  // namespace

int main(int argc, char** argv) {
  const tflite::Model* model = tflite::GetModel(g_hello_world_int8_model_data);
  HelloWorldOpResolver op_resolver;

  constexpr size_t kTensorArenaSize = 3000;
  uint8_t tensor_arena[kTensorArenaSize];

  tflite::MicroInterpreter interpreter(model, op_resolver, tensor_arena,
                                       kTensorArenaSize);

  if (interpreter.AllocateTensors() != kTfLiteOk) {
    return -1;
  }
  TfLiteTensor* input = interpreter.input(0);
  memset(tflite::GetTensorData<uint8_t>(input), 0, input->bytes);
  if (interpreter.Invoke() != kTfLiteOk) {
    return -2;
  }
  return 0;
}
