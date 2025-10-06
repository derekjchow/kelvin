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

"""Rules to build CoralNPU SW objects"""

load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain")

CORALNPU_V2_PLATFORM = "//platforms:coralnpu_v2"
CORALNPU_V2_SEMIHOSTING_PLATFORM = "//platforms:coralnpu_v2_semihosting"

def _coralnpu_v2_transition_impl(_settings, attr):
    if attr.semihosting:
        return {"//command_line_option:platforms": CORALNPU_V2_SEMIHOSTING_PLATFORM}
    else:
        return {"//command_line_option:platforms": CORALNPU_V2_PLATFORM}

_coralnpu_v2_transition = transition(
    implementation = _coralnpu_v2_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:platforms"],
)

def _coralnpu_v2_rule(**kwargs):
    """CoralNPU-specific transition rule.

    A wrapper over rule() for creating rules that trigger
    the transition to the coralnpu platform config.

    Args:
      **kwargs: params forwarded to the implementation.
    Returns:
      CoralNPU transition rule.
    """
    attrs = kwargs.pop("attrs", {})
    attrs["_allowlist_function_transition"] = attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    )

    return rule(
        cfg = _coralnpu_v2_transition,
        attrs = attrs,
        **kwargs
    )

def _coralnpu_v2_binary_impl(ctx):
    """Implements compilation for coralnpu executables.

    This rule compiles and links provided input into an executable
    suitable for use on the CoralNPU core. Generates an ELF.

    Args:
      ctx: context for the rules.
        srcs: Input source files.
        deps: Target libraries that the binary depends upon.
        hdrs: Header files that are local to the binary.
        copts: Flags to pass along to the compiler.
        defines: Preprocessor definitions.
        linkopts: Flags to pass along to the linker.

    Output:
        OutputGroupsInfo to allow definition of filegroups
        containing the output ELF and BIN.
    """
    cc_toolchain = find_cc_toolchain(ctx)
    if type(cc_toolchain) != 'CcToolchainInfo':
        cc_toolchain = cc_toolchain.cc
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    compilation_contexts = []
    linking_contexts = []
    for dep in ctx.attr.deps:
        if CcInfo in dep:
            compilation_contexts.append(dep[CcInfo].compilation_context)
            linking_contexts.append(dep[CcInfo].linking_context)

    sources = []
    headers = []
    for src in ctx.files.srcs:
        if src.extension in ["h", "hh", "hpp"]:
            headers.append(src)
        else:
            sources.append(src)

    (_compilation_context, compilation_outputs) = cc_common.compile(
        actions = ctx.actions,
        cc_toolchain = cc_toolchain,
        feature_configuration = feature_configuration,
        name = ctx.label.name,
        srcs = sources,
        compilation_contexts = compilation_contexts,
        private_hdrs = headers + ctx.files.hdrs,
        user_compile_flags = ctx.attr.copts,
        defines = ctx.attr.defines,
    )
    linking_outputs = cc_common.link(
        name = "{}.elf".format(ctx.label.name),
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = compilation_outputs,
        linking_contexts = linking_contexts,
        user_link_flags = ctx.attr.linkopts + [
            "-Wl,-T,{}".format(ctx.file.linker_script.path),
        ],
        additional_inputs = depset([ctx.file.linker_script] + ctx.files.linker_script_includes),
        output_type = "executable",
    )

    out_bin = ctx.actions.declare_file("{}.bin".format(ctx.label.name))
    objcopy_tool = cc_toolchain.objcopy_executable

    ctx.actions.run(
        outputs = [out_bin],
        inputs = [linking_outputs.executable] + cc_toolchain.all_files.to_list(),
        executable = objcopy_tool,
        arguments = [
            "-O",
            "binary",
            linking_outputs.executable.path,
            out_bin.path,
        ],
        mnemonic = "ObjCopy",
    )

    out_vmem = ctx.actions.declare_file("{}.vmem".format(ctx.label.name))
    word_size = ctx.attr.word_size
    srec_cat_vmem_args = [
        out_bin.path,
        "-binary",
        "-byte-swap",
        str(word_size // 8),
        "-fill",
        "0xff",
        "-within",
        out_bin.path,
        "-binary",
        "-range-pad",
        str(word_size // 8),
        "-o",
        out_vmem.path,
        "-vmem",
        str(word_size),
    ]
    ctx.actions.run(
        outputs = [out_vmem],
        inputs = [out_bin],
        executable = "srec_cat",
        arguments = srec_cat_vmem_args,
        mnemonic = "SrecCat",
    )

    return [
        DefaultInfo(
            files = depset([linking_outputs.executable, out_bin, out_vmem]),
        ),
        OutputGroupInfo(
            all_files = depset([linking_outputs.executable, out_bin, out_vmem]),
            elf_file = depset([linking_outputs.executable]),
            bin_file = depset([out_bin]),
            vmem_file = depset([out_vmem]),
        ),
    ]

_coralnpu_v2_binary = _coralnpu_v2_rule(
    implementation = _coralnpu_v2_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_empty = True, providers = [CcInfo]),
        "hdrs": attr.label_list(allow_files = [".h"], allow_empty = True),
        "copts": attr.string_list(),
        "defines": attr.string_list(),
        "linkopts": attr.string_list(),
        "linker_script": attr.label(allow_single_file = True),
        "linker_script_includes": attr.label_list(default = [], allow_files = True),
        "semihosting": attr.bool(),
        "word_size": attr.int(default = 32),
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
    },
    fragments = ["cpp"],
    toolchains = ["@rules_cc//cc:toolchain_type"],
)

def coralnpu_v2_binary(
        name,
        srcs,
        tags = [],
        semihosting = False,
        linker_script = "@coralnpu_hw//toolchain:coralnpu_tcm.ld",
        word_size = 32,
        **kwargs):
    """A helper macro for generating binary artifacts for the CoralNPU V2 core.

    This macro uses the coralnpu_v2 toolchain, libgloss-htif,
    and coralnpu linker script to build coralnpu binaries.

    Args:
      name: The name of this rule.
      srcs: The c source files.
      tags: build tags.
      semihosting: Enable htif-style semihosting
      linker_script: Linker script to construct the final binary.
      **kwargs: Additional arguments forward to cc_binary.
    Emits rules:
      filegroup              named: <name>.bin
        Containing the binary output for the target.
      filegroup              named: <name>.elf
        Containing all elf output for the target.
    """

    deps = kwargs.pop("deps", [])
    if not semihosting:
        deps.append("//toolchain/crt")

    _coralnpu_v2_binary(
        name = name,
        srcs = srcs,
        linker_script = linker_script,
        semihosting = semihosting,
        tags = tags,
        deps = deps,
        word_size = word_size,
        **kwargs
    )

    native.filegroup(
        name = "{}.elf".format(name),
        srcs = [name],
        output_group = "elf_file",
        tags = tags,
    )

    native.filegroup(
        name = "{}.vmem".format(name),
        srcs = [name],
        output_group = "vmem_file",
        tags = tags,
    )

    native.filegroup(
        name = "{}.bin".format(name),
        srcs = [name],
        output_group = "bin_file",
        tags = tags,
    )
