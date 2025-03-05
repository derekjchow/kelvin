load("//rules:coco_tb.bzl", "vcs_cocotb_test", "verilator_cocotb_test")
load("@kelvin_pip_deps//:requirements.bzl", "requirement")

verilator_cocotb_test(
    name = "core_mini_axi_sim_cocotb",
    size = "large",
    defines = {
        "USE_GENERIC" : "",
    },
    waves = True,
    hdl_toplevel = "CoreMiniAxi",
    seed = "42",
    test_module = ["core_mini_axi_sim.py"],
    verilog_sources = [
        "//hdl/chisel/src/kelvin:core_mini_axi_cc_library_verilog"
    ],
    deps = [
        requirement("pyelftools"),
        requirement("tqdm"),
    ],
    data = glob(["**/*.elf"]),
)

vcs_cocotb_test(
    name = "vcs_core_mini_axi_sim_cocotb",
    size = "large",
    defines = {
        "USE_GENERIC" : "",
    },
    waves = True,
    hdl_toplevel = "CoreMiniAxi",
    seed = "42",
    test_module = ["core_mini_axi_sim.py"],
    verilog_sources = [
        "//hdl/chisel/src/kelvin:core_mini_axi_cc_library_verilog"
    ],
    build_args = [
        "\"+define+SYNTHESIS=1 -timescale=1ns/1ps -kdb +vcs+fsdbon -debug_access+all -cm line+cond+tgl+branch+assert\"",
    ],
    test_args = [
        "\"+vcs+fsdbon -cm line+cond+tgl+branch+assert\"",
    ],
    deps = [
        requirement("pyelftools"),
        requirement("tqdm"),
    ],
    data = glob(["**/*.elf"]),
)
