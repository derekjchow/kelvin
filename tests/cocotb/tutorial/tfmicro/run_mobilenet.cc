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
#include "tests/cocotb/tutorial/tfmicro/mobilenet_v1_025_partial_layers.h"


namespace {
using MobilenetOpResolver = tflite::MicroMutableOpResolver<2>;
TfLiteStatus RegisterOps(MobilenetOpResolver& op_resolver) {
  TF_LITE_ENSURE_STATUS(op_resolver.AddConv2D());
  TF_LITE_ENSURE_STATUS(op_resolver.AddDepthwiseConv2D());
  return kTfLiteOk;
}
}  // namespace

extern "C" {
// aligned(16)
constexpr size_t kTensorArenaSize = 256 * 1024;
uint8_t inference_status __attribute__((section(".extdata"), aligned(16), used, retain));
uint8_t tensor_arena[kTensorArenaSize] __attribute__((section(".extdata"), aligned(16), used, retain));
}

int main(int argc, char** argv) {
  const tflite::Model* model = tflite::GetModel(g_mobilenet_v1_025_partial_layers_model_data);
  MobilenetOpResolver op_resolver;
  RegisterOps(op_resolver);
  inference_status = 3;
  tflite::MicroInterpreter interpreter(model, op_resolver, tensor_arena,
                                       kTensorArenaSize);
  if (interpreter.AllocateTensors() != kTfLiteOk) {
    return -1;
  }
  inference_status = 4;
  TfLiteTensor* input = interpreter.input(0);
  memset(input->data.int8, 9, input->bytes);
  interpreter.Invoke();
  inference_status = 5;
  return 0;
}
