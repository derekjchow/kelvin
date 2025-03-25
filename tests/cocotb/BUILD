
load("//rules:coco_tb.bzl", "vcs_cocotb_test", "verilator_cocotb_test")
load("//rules:utils.bzl", "template_rule")
load("@kelvin_pip_deps//:requirements.bzl", "requirement")

template_rule(
    verilator_cocotb_test,
    {
        "core_mini_axi_sim_cocotb": {
            "hdl_toplevel": "CoreMiniAxi",
            "verilog_sources": [
                "//hdl/chisel/src/kelvin:core_mini_axi_cc_library_verilog"
            ],
            "size": "large",
        },
        "rvv_core_mini_axi_sim_cocotb": {
            "hdl_toplevel": "RvvCoreMiniAxi",
            "verilog_sources": [
                "//hdl/chisel/src/kelvin:rvv_core_mini_axi_cc_library_verilog"
            ],
            "size": "enormous",
            "tags": ["manual"], # This suite takes a really long time
        },
    },
    build_args = [
        "-Wno-WIDTH",
        "-Wno-CASEINCOMPLETE",
        "-Wno-LATCH",
        "-Wno-SIDEEFFECT",
        "-Wno-MULTIDRIVEN",
        "-Wno-UNOPTFLAT",
        "-Wno-CASEOVERLAP",
    ],
    defines = {
        "USE_GENERIC" : "",
    },
    waves = True,
    seed = "42",
    test_module = ["core_mini_axi_sim.py"],
    deps = [
        requirement("pyelftools"),
        requirement("tqdm"),
    ],
    data = glob(["**/*.elf"]) + glob(["**/*.o"]),
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
    data = glob(["**/*.elf"]) + glob(["**/*.o"]),
)
