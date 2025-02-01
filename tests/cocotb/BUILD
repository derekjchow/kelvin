load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@kelvin_pip_deps//:requirements.bzl", "requirement")
load("@rules_hdl//cocotb:cocotb.bzl", "cocotb_test")

cocotb_test(
    name = "core_mini_axi_sim_cocotb",
    # TODO(derekjchow): Set path correctly
    sim = ["@verilator//:verilator_executable"],
    sim_name = "verilator",
    defines = {
        "USE_GENERIC" : "",
    },
    waves = True,
    hdl_toplevel = "CoreMiniAxi",
    hdl_toplevel_lang = "verilog",
    seed = "9001",
    test_module = ["core_mini_axi_sim.py"],
    verilog_sources = [
        "//hdl/chisel/src/kelvin:core_mini_axi_cc_library_verilog"
    ],
    deps = [
        requirement("cocotb"),
        requirement("numpy"),
    ],
)