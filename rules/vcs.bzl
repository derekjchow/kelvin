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

def _vcs_testbench_test_impl(ctx):
    transitive_srcs = depset([], transitive = [ctx.attr.deps[VerilogInfo].dag])
    all_srcs = [verilog_info_struct.srcs
                for verilog_info_struct in transitive_srcs.to_list()]
    all_files = [src for sub_tuple in all_srcs for src in sub_tuple]
    for src in ctx.files.srcs:
      all_files.append(src)

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
