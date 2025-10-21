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

"""Convenience wrapper for Verilator driven cocotb."""

load("@coralnpu_hw//third_party/python:requirements.bzl", "requirement")
load("@rules_hdl//cocotb:cocotb.bzl", "cocotb_test")
load("@rules_python//python:defs.bzl", "py_library")

def _verilator_cocotb_model_impl(ctx):
    """Implementation of the verilator_cocotb_model rule."""
    cc_toolchain = ctx.toolchains["@bazel_tools//tools/cpp:toolchain_type"].cc
    ar_executable = cc_toolchain.ar_executable
    compiler_executable = cc_toolchain.compiler_executable
    ld_executable = cc_toolchain.ld_executable
    hdl_toplevel = ctx.attr.hdl_toplevel
    outdir_name = hdl_toplevel + "_build"

    vlt_file = ctx.actions.declare_file(hdl_toplevel + ".vlt")
    ctx.actions.expand_template(
        output = vlt_file,
        template = ctx.file.vlt_tpl,
        substitutions = {"{HDL_TOPLEVEL}": hdl_toplevel},
    )

    output_file = ctx.actions.declare_file(outdir_name + "/" + hdl_toplevel)
    make_log = ctx.actions.declare_file(outdir_name + "/make.log")
    outdir = output_file.dirname

    verilator_root = "$PWD/{}.runfiles/coralnpu_hw/external/verilator".format(ctx.executable._verilator_bin.path)
    cocotb_lib_path = "$PWD/{}".format(ctx.files._cocotb_verilator_lib[0].dirname)
    verilator_cmd = " ".join("""
        VERILATOR_ROOT={verilator_root} {verilator} \
            -cc \
            --exe \
            -Mdir {outdir} \
            --top-module {hdl_toplevel} \
            --vpi \
            --prefix Vtop \
            -o {hdl_toplevel} \
            -LDFLAGS "-Wl,-rpath {cocotb_lib_path} -L{cocotb_lib_path} -lcocotbvpi_verilator" \
            {trace} \
            {cflags} \
            $PWD/{verilator_cpp} \
            {vlt_file} \
            {verilog_source}
    """.strip().split("\n")).format(
        verilator = ctx.executable._verilator_bin.path,
        verilator_root = verilator_root,
        outdir = outdir,
        hdl_toplevel = hdl_toplevel,
        cocotb_lib_path = cocotb_lib_path,
        cflags = " ".join(ctx.attr.cflags),
        verilator_cpp = ctx.files._cocotb_verilator_cpp[0].path,
        vlt_file = vlt_file.path,
        verilog_source = ctx.file.verilog_source.path,
        trace = "--trace" if ctx.attr.trace else "",
    )

    make_cmd = "PATH=`dirname {ld}`:$PATH make -j $(nproc) -C {outdir} -f Vtop.mk {trace} CXX={cxx} AR={ar} LINK={cxx} > {make_log} 2>&1".format(
        outdir = outdir,
        cocotb_lib_path = cocotb_lib_path,
        make_log = make_log.path,
        trace = "VM_TRACE=1" if ctx.attr.trace else "",
        ar = ar_executable,
        ld = ld_executable,
        cxx = compiler_executable,
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
                depset([vlt_file]),
            ],
        ),
        command = script,
        mnemonic = "Verilate",
    )

    return [
        DefaultInfo(
            files = depset([output_file, make_log]),
            runfiles = ctx.runfiles(files = [output_file, make_log]),
            executable = output_file,
        ),
        OutputGroupInfo(
            all_files = depset([output_file, make_log]),
        ),
    ]

verilator_cocotb_model = rule(
    doc = """Builds a verilator model for cocotb.

    This rule takes a verilog source file and a toplevel module name and
    builds a verilator model that can be used with cocotb.

    It returns a DefaultInfo provider with an executable that can be run
    to execute the simulation.

    Attributes:
        verilog_source: The verilog source file to build the model from.
        hdl_toplevel: The name of the toplevel module.
        cflags: A list of flags to pass to the compiler.
    """,
    implementation = _verilator_cocotb_model_impl,
    attrs = {
        "verilog_source": attr.label(allow_single_file = True, mandatory = True),
        "hdl_toplevel": attr.string(mandatory = True),
        "cflags": attr.string_list(default = []),
        "trace": attr.bool(default = False),
        "vlt_tpl": attr.label(
            default = "@coralnpu_hw//rules:default.vlt.tpl",
            allow_single_file = True,
        ),
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
            default = "@coralnpu_pip_deps_cocotb//:verilator_libs",
            allow_files = True,
        ),
        "_cocotb_verilator_cpp": attr.label(
            default = "@coralnpu_pip_deps_cocotb//:verilator_srcs",
            allow_files = True,
        ),
    },
    executable = True,
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)

def verilator_cocotb_test(
        name,
        model,
        hdl_toplevel,
        test_module,
        deps = [],
        data = [],
        **kwargs):
    """Runs a cocotb test with a verilator model.

    This is a wrapper around the cocotb_test rule that is specific to
    verilator.

    Args:
        name: The name of the test.
        model: The verilator_cocotb_model target to use.
        hdl_toplevel: The name of the toplevel module.
        test_module: The python module that contains the test.
        deps: Additional dependencies for the test.
        data: Data dependencies for the test.
        **kwargs: Additional arguments to pass to the cocotb_test rule.
    """
    kwargs.update(
        hdl_toplevel_lang = "verilog",
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
        **kwargs
    )

def _verilator_cocotb_test_suite(
        name,
        model,
        testcases = [],
        testcases_vname = "",
        tests_kwargs = {},
        **kwargs):
    """Runs a cocotb test with a verilator model.

    This is a wrapper around the cocotb_test rule that is specific to
    verilator.

    Args:
        name: The name of the test.
        model: The verilator_cocotb_model target to use.
        testcases: A list of testcases to run. A test will be generated for each
          testcase.
        tests_kwargs: A dictionary of arguments to pass to the cocotb_test rule.
        **kwargs: Additional arguments to pass to the cocotb_test rule.
    """
    all_tests_kwargs = dict(tests_kwargs)
    all_tests_kwargs.update(kwargs)

    if testcases:
        test_targets = []
        for tc in testcases:
            tc_tests_kwargs = dict(all_tests_kwargs)
            tags = list(tc_tests_kwargs.pop("tags", []))
            tags.append("manual")
            tags.append("verilator_cocotb_single_test")
            verilator_cocotb_test(
                name = "{}_{}".format(name, tc),
                model = model,
                testcase = [tc],
                tags = tags,
                **tc_tests_kwargs
            )
            test_targets.append(":{}_{}".format(name, tc))

    # Generate a meta-target for all tests.
    meta_target_kwargs = dict(all_tests_kwargs)
    tags = list(meta_target_kwargs.pop("tags", []))
    tags.append("verilator_cocotb_test_suite")
    if testcases_vname:
        tags.append("testcases_vname={}".format(testcases_vname))
    verilator_cocotb_test(
        name = name,
        model = model,
        tags = tags,
        **meta_target_kwargs
    )

def vcs_cocotb_test(
        name,
        hdl_toplevel,
        test_module,
        deps = [],
        data = [],
        **kwargs):
    """Runs a cocotb test with a vcs model.

    This is a wrapper around the cocotb_test rule that is specific to
    vcs.

    Args:
        name: The name of the test.
        hdl_toplevel: The name of the toplevel module.
        test_module: The python module that contains the test.
        deps: Additional dependencies for the test.
        data: Data dependencies for the test.
        **kwargs: Additional arguments to pass to the cocotb_test rule.
    """
    tags = list(kwargs.pop("tags", []))
    tags.append("vcs")
    kwargs.update(
        hdl_toplevel_lang = "verilog",
        sim_name = "vcs",
        sim = [],
        tags = tags,
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
        hdl_toplevel = hdl_toplevel,
        test_module = test_module,
        deps = [
            ":{}_test_data".format(name),
        ],
        **kwargs
    )

def _vcs_cocotb_test_suite(
        name,
        verilog_sources,
        testcases = [],
        testcases_vname = "",
        tests_kwargs = {},
        **kwargs):
    """Runs a cocotb test with a vcs model.

    This is a wrapper around the cocotb_test rule that is specific to
    vcs.

    Args:
        name: The name of the test.
        verilog_sources: The verilog sources to use for the test.
        testcases: A list of testcases to run. A test will be generated for each
          testcase.
        tests_kwargs: A dictionary of arguments to pass to the cocotb_test rule.
        **kwargs: Additional arguments to pass to the cocotb_test rule.
    """
    all_tests_kwargs = dict(tests_kwargs)
    all_tests_kwargs.update(kwargs)

    hdl_toplevel = all_tests_kwargs.get("hdl_toplevel")
    if not hdl_toplevel:
        fail("hdl_toplevel must be specified in tests_kwargs")

    if testcases:
        test_targets = []
        for tc in testcases:
            tc_tests_kwargs = dict(all_tests_kwargs)
            tags = list(tc_tests_kwargs.pop("tags", []))
            tags.append("manual")
            tags.append("vcs_cocotb_single_test")
            test_args = tc_tests_kwargs.pop("test_args", [""])
            vcs_cocotb_test(
                name = "{}_{}".format(name, tc),
                testcase = [tc],
                tags = tags,
                test_args = ["{} -cm_name {}".format(test_args[0], tc)] + test_args[1:],
                verilog_sources = verilog_sources,
                **tc_tests_kwargs
            )
            test_targets.append(":{}_{}".format(name, tc))

    # Generate a meta-target for all tests.
    meta_target_kwargs = dict(all_tests_kwargs)
    tags = list(meta_target_kwargs.pop("tags", []))
    tags.append("vcs_cocotb_test_suite")
    vcs_cocotb_test(
        name = name,
        tags = tags,
        verilog_sources = verilog_sources,
        **meta_target_kwargs
    )

def cocotb_test_suite(name, testcases, simulators = ["verilator"], **kwargs):
    """Runs a cocotb test with a verilator or vcs model.

    This is a wrapper around the cocotb_test rule that is specific to
    verilator.

    Args:
        name: The name of the test.
        simulators: A list of simulators to run the test with.
          Supported simulators are "verilator" and "vcs".
        **kwargs: Additional arguments to pass to the cocotb_test rule.
          These can be prefixed with the simulator name to apply them to
          only that simulator.
    """

    # Pop tests_kwargs from kwargs, if it exists.
    tests_kwargs = kwargs.pop("tests_kwargs", {})
    testcases_vname = kwargs.pop("testcases_vname", "")
    for sim in simulators:
        sim_kwargs = {}
        sim_tests_kwargs = dict(tests_kwargs)

        # Partition kwargs into sim_kwargs
        for key, value in kwargs.items():
            if key.startswith(sim):
                sim_kwargs[key.replace(sim + "_", "")] = value

        # Partition tests_kwargs into sim_tests_kwargs
        for key, value in tests_kwargs.items():
            if key.startswith(sim):
                sim_tests_kwargs[key.replace(sim + "_", "")] = value

        # Remove sim-specific kwargs from tests_kwargs
        for key, value in tests_kwargs.items():
            if key.startswith(sim):
                if key in sim_tests_kwargs:
                    sim_tests_kwargs.pop(key)

        if sim == "verilator":
            model = sim_kwargs.pop("model", None)
            if not model:
                fail("verilator_model must be specified for verilator tests")
            _verilator_cocotb_test_suite(
                name = name,
                model = model,
                testcases = testcases,
                testcases_vname = testcases_vname,
                tests_kwargs = sim_tests_kwargs,
                **sim_kwargs
            )
        elif sim == "vcs":
            verilog_sources = sim_kwargs.pop("verilog_sources", [])
            if not verilog_sources:
                fail("vcs_verilog_sources must be specified for vcs tests")
            _vcs_cocotb_test_suite(
                name = "{}_{}".format(sim, name),
                verilog_sources = verilog_sources,
                testcases = testcases,
                testcases_vname = testcases_vname,
                tests_kwargs = sim_tests_kwargs,
                **sim_kwargs
            )
        else:
            fail("Unknown simulator: {}".format(sim))