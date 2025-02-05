load("//rules:coco_tb.bzl", "verilator_cocotb_test")
load("@kelvin_pip_deps//:requirements.bzl", "requirement")

verilator_cocotb_test(
    name = "core_mini_axi_sim_cocotb",
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
    ],
)