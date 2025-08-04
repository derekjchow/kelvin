"""Starlark rules for FPGA development."""

def _tlgen_impl(ctx):
    """Implementation of the tlgen_rule."""
    topcfg = ctx.file.topcfg
    out_dir = ctx.actions.declare_directory(ctx.label.name + "_out")
    core_file = ctx.actions.declare_file(ctx.label.name + "_out/" + "xbar_kelvin_soc_xbar.core")

    ctx.actions.run(
        outputs = [out_dir, core_file],
        inputs = [topcfg],
        executable = ctx.executable._tool,
        arguments = [
            "--topcfg",
            topcfg.path,
            "--outdir",
            out_dir.path,
        ],
        progress_message = "Running tlgen and extracting core for %s" % topcfg.short_path,
    )

    return [
        DefaultInfo(files = depset([out_dir])),
        OutputGroupInfo(
            core_file_output = depset([core_file, out_dir]),
        ),
    ]

tlgen_rule = rule(
    implementation = _tlgen_impl,
    attrs = {
        "topcfg": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "HJSON top-level configuration file.",
        ),
        "_tool": attr.label(
            default = Label("//fpga:tlgen_tool"),
            executable = True,
            cfg = "exec",
        ),
    },
)
