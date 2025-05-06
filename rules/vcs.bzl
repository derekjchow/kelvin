# Copyright 2024 Google LLC
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

"""Bazel functions for VCS."""

load("@rules_hdl//verilog:providers.bzl", "VerilogInfo")

def _collect_verilog_files(dep):
    transitive_srcs = depset([], transitive = [dep[VerilogInfo].dag])
    all_srcs = [verilog_info_struct.srcs
                for verilog_info_struct in transitive_srcs.to_list()]
    all_files = [src for sub_tuple in all_srcs for src in sub_tuple]
    return all_files

def _vcs_testbench_test_impl(ctx):
    all_files = _collect_verilog_files(ctx.attr.deps)

    vcs_binary_output = ctx.actions.declare_file(ctx.attr.module)
    vcs_daidir_output = ctx.actions.declare_directory(
        ctx.attr.module + ".daidir")

    verilog_files = []
    for file in all_files:
        if file.extension in ["dat", "mem"]:
            continue
        verilog_files.append(file)

    command = [
        "vcs",
        "-full64",
        "-sverilog",
    ]
    verilog_dirs = dict()
    for file in verilog_files:
        verilog_dirs[file.dirname] = None
    for verilog_file in verilog_files:
        command.append(verilog_file.path)
    command.append("-o")
    command.append(vcs_binary_output.path)

    ctx.actions.run_shell(
        outputs=[vcs_binary_output, vcs_daidir_output],
        inputs=verilog_files,
        command = " ".join(command),
        use_default_shell_env = True,
    )

    return [DefaultInfo(runfiles=ctx.runfiles(files=[vcs_daidir_output]),
                        executable=vcs_binary_output)]

_vcs_testbench_test = rule(
    _vcs_testbench_test_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label(
            doc = "The verilog target to create a test bench for.",
            providers = [VerilogInfo],
            mandatory = True,
        ),
        "module": attr.string(
            doc = "The name of the verilog module to verilate.",
            mandatory = True,
        ),
    },
    test = True,
)

def vcs_testbench_test(name, tags=[], **kwargs):
    _vcs_testbench_test(name = name, tags = ["vcs"] + tags, **kwargs)

def _vcs_systemc_binary_impl(ctx):
    verilog_files = []
    for dep in ctx.attr.verilog_deps:
        verilog_files += _collect_verilog_files(dep)
    systemc_include_paths = []
    systemc_link_args = []
    libs = []

    for dep in ctx.attr.systemc_deps:
        transitive_quote_includes = depset([], transitive = [dep[CcInfo].compilation_context.quote_includes])
        transitive_system_includes = depset([], transitive = [dep[CcInfo].compilation_context.system_includes])
        for include in transitive_quote_includes.to_list():
            if include.find('accellera_systemc') == -1:
                systemc_include_paths += ["-cflags", "-I" + include]
        for include in transitive_system_includes.to_list():
            if include.find('accellera_systemc') == -1:
                systemc_include_paths += ["-cflags", "-I" + include]
        transitive_linker_inputs = depset([], transitive = [dep[CcInfo].linking_context.linker_inputs])
        for link in transitive_linker_inputs.to_list():
            for library in link.libraries:
                if library.pic_static_library:
                    if library.pic_static_library.path.find('accellera_systemc') == -1:
                        libs.append(library.pic_static_library)
                elif library.static_library:
                    if library.static_library.path.find('accellera_systemc') == -1:
                        libs.append(library.static_library)
                if library.pic_objects:
                    for object in library.pic_objects:
                        systemc_link_args.append(object.path)

    vcs_binary_output = ctx.actions.declare_file(ctx.attr.name)
    vlogan_command = [
        "vlogan",
        "-kdb",
        "-full64",
        "-sverilog",
        "-sysc",
        "-q",
        "-incr_vlogan",
        "+define+SIMULATION",
    ] + ctx.attr.build_args
    vlogan_outputs = []
    verilog_files += ctx.files.verilog_srcs
    verilog_include_paths = []
    for f in verilog_files:
        verilog_include_paths  += ["-cflags", "-I" + f.dirname]
    for (i, file) in enumerate(verilog_files):
        vlogan_output = ctx.actions.declare_file(file.path + ".stamp")
        vlogan_outputs.append(vlogan_output)
        main_module_args = []
        if file.basename.startswith(ctx.attr.module):
            main_module_args += ["-sc_model", ctx.attr.module]
        if file.basename.startswith(ctx.attr.module) and ctx.attr.portmap:
            main_module_args += ["-sc_portmap", ctx.file.portmap.path]
        prev_input = [vlogan_outputs[i-1]] if i > 0 else []
        ctx.actions.run_shell(
            command = " ".join(
                vlogan_command +
                main_module_args +
                [file.path, "&&", "touch", vlogan_output.path]
            ),
            outputs = [vlogan_output],
            inputs = [file] + prev_input,
            use_default_shell_env = True,
            progress_message = "[VLOGAN] %{input}",
        )

    syscan_command = [
        "syscan",
        "-cflags",
        "-g",
        "-full64",
        "-q",
    ] + verilog_include_paths + systemc_include_paths
    syscan_outputs = []
    for (i, file) in enumerate(ctx.files.systemc_srcs):
        syscan_output = ctx.actions.declare_file(file.path + ".stamp")
        syscan_outputs.append(syscan_output)
        prev_input = [syscan_outputs[i-1]] if i > 0 else [vlogan_outputs[-1]]
        ctx.actions.run_shell(
            command = " ".join(
                syscan_command + [file.path, "&&", "touch", syscan_output.path]
            ),
            inputs = vlogan_outputs + prev_input + [file],
            outputs = [syscan_output],
            use_default_shell_env = True,
            progress_message = "[SYSCAN] %{input}",
        )

    vcs_daidir_output = ctx.actions.declare_directory(
        ctx.attr.name + ".daidir")
    vcs_vdb_output = ctx.actions.declare_directory(
        ctx.attr.name + ".vdb")
    vcs_command = [
        "vcs",
        "-full64",
        "-sverilog",
        "-q",
        "-cflags", "-g",
        "-sysc=incr",
        "-kdb",
        "+vcs+fsdbon",
        "-debug_access+all",
        "+notimingcheck",
        "-timescale=1ns/1ps",
        "-cm", "line+tgl+fsm+cond+branch+assert",
        "sc_main",
        "-o",
        vcs_binary_output.path,
    ] + systemc_link_args
    ctx.actions.run_shell(
        command = " ".join(vcs_command),
        inputs = libs + vlogan_outputs + syscan_outputs,
        outputs = [vcs_binary_output, vcs_daidir_output, vcs_vdb_output],
        use_default_shell_env = True,
    )

    return [DefaultInfo(
        files=depset([vcs_binary_output]),
        runfiles=ctx.runfiles(files=[vcs_daidir_output, vcs_vdb_output]),
        executable=vcs_binary_output,
    )]

_vcs_systemc_binary = rule(
    _vcs_systemc_binary_impl,
    attrs = {
        "verilog_srcs": attr.label_list(allow_files = True),
        "systemc_srcs": attr.label_list(allow_files = True),
        "verilog_deps": attr.label_list(
            doc = "Verilog library dependencies",
            providers = [VerilogInfo],
        ),
        "build_args": attr.string_list(allow_empty = True),
        "systemc_deps": attr.label_list(
            doc = "SystemC library dependencies",
            providers = [CcInfo],
        ),
        "portmap": attr.label(allow_single_file = True),
        "module": attr.string(
            doc = "The name of the main verilog module.",
            mandatory = True,
        ),
        "_cc_toolchain": attr.label(
            doc = "CC compiler.",
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    toolchains = [
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    executable = True,
)

def vcs_systemc_binary(name, tags=[], **kwargs):
    _vcs_systemc_binary(name = name, tags = ["vcs"] + tags, **kwargs)
