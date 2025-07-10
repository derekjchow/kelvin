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

"""Convinence wrapper for Verilator driven cocotb."""

load("@kelvin_hw//third_party/python:requirements.bzl", "requirement")
load("@rules_hdl//cocotb:cocotb.bzl", "cocotb_test")
load("@rules_python//python:defs.bzl", "py_library")

def _verilator_cocotb_model_impl(ctx):
    hdl_toplevel = ctx.attr.hdl_toplevel
    outdir_name = hdl_toplevel + "_build"

    output_file = ctx.actions.declare_file(outdir_name + "/" + hdl_toplevel)
    make_log = ctx.actions.declare_file(outdir_name + "/make.log")
    outdir = output_file.dirname

    verilator_root = "$PWD/{}.runfiles/kelvin_hw/external/verilator".format(ctx.executable._verilator_bin.path)
    cocotb_lib_path = "$PWD/{}".format(ctx.files._cocotb_verilator_lib[0].dirname)
    verilator_cmd = " ".join("""
        VERILATOR_ROOT={verilator_root} {verilator} \
            -cc \
            --exe \
            -Mdir {outdir} \
            --top-module {hdl_toplevel} \
            --vpi \
            --public-flat-rw \
            --prefix Vtop \
            -o {hdl_toplevel} \
            -LDFLAGS "-Wl,-rpath external/kelvin_pip_deps_cocotb/cocotb/lib -L{cocotb_lib_path} -lcocotbvpi_verilator" \
            {cflags} \
            $PWD/{verilator_cpp} \
            {verilog_source}
    """.strip().split("\n")).format(
        verilator = ctx.executable._verilator_bin.path,
        verilator_root = verilator_root,
        outdir = outdir,
        hdl_toplevel = hdl_toplevel,
        cocotb_lib_path = cocotb_lib_path,
        cflags = " ".join(ctx.attr.cflags),
        verilator_cpp = ctx.files._cocotb_verilator_cpp[0].path,
        verilog_source = ctx.file.verilog_source.path,
    )

    make_cmd = "PATH=`dirname $(which ld)`:$PATH make -j $(nproc) -C {outdir} -f Vtop.mk CXX=`which g++` AR=`which ar` LINK=`which g++` > {make_log} 2>&1".format(
        outdir=outdir,
        cocotb_lib_path=cocotb_lib_path,
        make_log=make_log.path,
    )

    script = " && ".join([verilator_cmd.strip(), make_cmd])

    ctx.actions.run_shell(
        outputs = [output_file, make_log],
        tools = ctx.files._verilator_bin,
        inputs = depset(
            transitive = [
                depset(ctx.files._verilator),
                depset(ctx.files._cocotb_verilator_lib),
                depset(ctx.files._cocotb_verilator_cpp),
                depset([ctx.file.verilog_source]),
            ],
        ),
        command = script,
        mnemonic = "Verilate",
    )

    return [
        DefaultInfo(
            files = depset([output_file, make_log]),
            runfiles = ctx.runfiles(files=[output_file, make_log]),
            executable = output_file,
        ),
        OutputGroupInfo(
            all_files = depset([output_file, make_log]),
        ),
    ]

verilator_cocotb_model = rule(
    implementation = _verilator_cocotb_model_impl,
    attrs = {
        "verilog_source": attr.label(allow_single_file = True, mandatory = True),
        "hdl_toplevel": attr.string(mandatory = True),
        "cflags": attr.string_list(default = []),
        "_verilator": attr.label(
            default = "@verilator//:verilator",
            executable = True,
            cfg = "exec",
        ),
        "_verilator_bin": attr.label(
            default = "@verilator//:verilator_bin",
            executable = True,
            cfg = "exec",
        ),
        "_cocotb_verilator_lib": attr.label(
            default = "@kelvin_pip_deps_cocotb//:verilator_libs",
            allow_files = True,
        ),
        "_cocotb_verilator_cpp": attr.label(
            default = "@kelvin_pip_deps_cocotb//:verilator_srcs",
            allow_files = True,
        ),
    },
    executable = True,
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)

def verilator_cocotb_test(name,
                          model,
                          hdl_toplevel,
                          test_module,
                          deps=[],
                          data=[],
                          **kwargs):
    kwargs.update(
        hdl_toplevel_lang="verilog",
        sim_name = "verilator",
        sim = [
            "@verilator//:verilator",
            "@verilator//:verilator_bin",
        ],
    )

    # Wrap in py_library so we can forward data
    py_library(
        name = name + "_test_data",
        srcs = [],
        deps = deps + [
            requirement("cocotb"),
            requirement("numpy"),
            requirement("pytest"),
        ],
        data = data,
    )

    cocotb_test(
        name = name,
        model = model,
        hdl_toplevel = hdl_toplevel,
        test_module = test_module,
        deps = [
            ":{}_test_data".format(name),
        ],
        **kwargs,
    )

def vcs_cocotb_test(name,
                    hdl_toplevel,
                    test_module,
                    testcases=[],
                    deps=[],
                    data=[],
                    **kwargs):
    tags = kwargs.pop("tags", [])
    tags.append("vcs")
    kwargs.update(
        hdl_toplevel_lang="verilog",
        sim_name = "vcs",
        sim = [],
        tags = tags)

    # Wrap in py_library so we can forward data
    py_library(
        name = name + "_test_data",
        srcs = [],
        deps = deps + [
            requirement("cocotb"),
            requirement("numpy"),
            requirement("pytest"),
        ],
        data = data,
    )

    test_args = kwargs.pop("test_args", [""])
    [cocotb_test(
        name = "{}_{}".format(name, tc),
        hdl_toplevel = hdl_toplevel,
        test_module = test_module,
        testcase = [tc],
        test_args = ["{} -cm_name {}".format(test_args[0], tc)] + test_args[1:],
        deps = [
            ":{}_test_data".format(name),
        ],
        **kwargs,
    ) for tc in testcases]
