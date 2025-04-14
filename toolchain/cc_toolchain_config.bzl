# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "tool_path",
)

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

all_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.clif_match,
]

def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "clang",
            path = "wrappers/clang",
        ),
        tool_path(
            name = "gcc",
            path = "wrappers/g++",
        ),
        tool_path(
            name = "ld",
            path = "wrappers/ld",
        ),
        tool_path(
            name = "ar",
            path = "wrappers/ar",
        ),
        tool_path(
            name = "cpp",
            path = "wrappers/cpp",
        ),
        tool_path(
            name = "gcov",
            path = "/bin/false",
        ),
        tool_path(
            name = "nm",
            path = "/bin/false",
        ),
        tool_path(
            name = "objdump",
            path = "/bin/false",
        ),
        tool_path(
            name = "strip",
            path = "/bin/false",
        ),
    ]

    # This is huge. Won't fit in 8K itcm,
    # but should fit in the highmem variant.
    printf_float_feature = feature(
        name = "printf_float",
        enabled = False,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-u",
                            "_printf_float",
                        ],
                    ),
                ],
            ),
        ],
    )

    warnings_feature = feature(
        name = "warnings",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wall",
                            "-Werror",
                        ],
                    ),
                ],
            ),
        ],
    )

    includes_feature = feature(
        name = "includes",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-nostdinc",
                            "-isystem",
                            "external/toolchain_kelvin_v2/riscv32-unknown-elf/include/c++/15.0.1",
                            "-isystem",
                            "external/toolchain_kelvin_v2/riscv32-unknown-elf/include/c++/15.0.1/backward",
                            "-isystem",
                            "external/toolchain_kelvin_v2/riscv32-unknown-elf/include/c++/15.0.1/riscv32-unknown-elf",
                            "-isystem",
                            "external/toolchain_kelvin_v2/lib/gcc/riscv32-unknown-elf/15.0.1/include",
                            "-isystem",
                            "external/toolchain_kelvin_v2/riscv32-unknown-elf/include",
                        ],
                    ),
                ],
            ),
        ],
    )

    optimization_compile_flag_set = flag_set(
        actions = all_compile_actions,
        flag_groups = [
            flag_group(
                flags = [
                    "-Os",
                    "-ffunction-sections",
                    "-fdata-sections",
                    "-ffreestanding",
                ],
            ),
        ],
    )

    optimization_link_flag_set = flag_set(
        actions = all_link_actions,
        flag_groups = [
            flag_group(
                flags = [
                    "-Wl,--gc-sections",
                ],
            ),
        ],
    )

    architecture_flag_set = flag_set(
        actions = all_compile_actions,
        flag_groups = [
            flag_group(
                flags = [
                    "-march=rv32imf_zve32x_zicsr_zifencei_zbb",
                    "-mabi=ilp32",
                    "-mcmodel=medany",
                    "-nostdlib",
                ],
            ),
        ],
    )

    nano_spec_flag_set = flag_set(
        actions = all_link_actions,
        flag_groups = [
            flag_group(
                flags = [
                    "--specs=nano.specs",
                    "-lm",
                    "-lc",
                    "-lgcc",
                    "-nostartfiles",
                ],
            ),
        ],
    )

    semihosting_spec_flag_set = flag_set(
        actions = all_link_actions,
        flag_groups = [
            flag_group(
                flags = [
                    "--specs=htif_nano.specs",
                    "-lsemihost",
                    "-lm",
                    "-lc",
                    "-lgcc",
                ],
            ),
        ],
    )

    spec_flag_set = semihosting_spec_flag_set if ctx.attr.semihosting else nano_spec_flag_set

    sys_feature = feature(
        name = "sys_spec",
        enabled = True,
        flag_sets = [
            architecture_flag_set,
            optimization_compile_flag_set,
            optimization_link_flag_set,
            spec_flag_set,
        ],
    )

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "kelvin_v2_toolchain",
        host_system_name = "local",
        target_system_name = "kelvin_v2",
        target_cpu = "riscv32",
        target_libc = "newlib",
        compiler = "clang",
        abi_version = "ilp32",
        abi_libc_version = "ilp32",
        features = [
            includes_feature,
            printf_float_feature,
            sys_feature,
            warnings_feature,
        ],
        tool_paths = tool_paths,
    )

kelvin_v2_cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "semihosting": attr.bool()
    },
    provides = [CcToolchainConfigInfo],
)
