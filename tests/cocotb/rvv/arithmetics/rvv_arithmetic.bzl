"""Generate a rvv test script using the template below"""

def rvv_arithmetic_test(**kwargs):
    rvv_arithmetic_template(
        source_file = "{name}.cc".format(**kwargs),
        **kwargs
    )

def rvv_reduction_test(**kwargs):
    rvv_reduction_template(
        source_file = "{name}.cc".format(**kwargs),
        **kwargs
    )

def rvv_widen_arithmetic_test(**kwargs):
    rvv_widen_arithmetic_template(
        source_file = "{name}.cc".format(**kwargs),
        **kwargs
    )

def rvv_arithmetic_template_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = ctx.outputs.source_file,
        substitutions = {
            "{DTYPE}": ctx.attr.dtype,
            "{IN_DATA_SIZE}": ctx.attr.in_data_size,
            "{OUT_DATA_SIZE}": ctx.attr.out_data_size,
            "{MATH_OP}": ctx.attr.math_op,
            "{NUM_OPERANDS}": ctx.attr.num_operands,
            "{SEW}": ctx.attr.sew,
            "{SIGN}": ctx.attr.sign,
        },
    )

def rvv_reduction_template_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = ctx.outputs.source_file,
        substitutions = {
            "{DTYPE}": ctx.attr.dtype,
            "{IN_DATA_SIZE}": ctx.attr.in_data_size,
            "{OUT_DATA_SIZE}": ctx.attr.out_data_size,
            "{REDUCTION_OP}": ctx.attr.reduction_op,
            "{NUM_OPERANDS}": ctx.attr.num_operands,
            "{SEW}": ctx.attr.sew,
            "{SIGN}": ctx.attr.sign,
        },
    )

def rvv_widen_arithmetic_template_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = ctx.outputs.source_file,
        substitutions = {
            "{IN_DTYPE}": ctx.attr.in_dtype,
            "{OUT_DTYPE}": ctx.attr.out_dtype,
            "{IN_SEW}": ctx.attr.in_sew,
            "{OUT_SEW}": ctx.attr.out_sew,
            "{STEP_OPERANDS}": ctx.attr.step_operands,
            "{MATH_OP}": ctx.attr.math_op,
            "{SIGN}": ctx.attr.sign,
            "{NUM_TEST_VALUES}": ctx.attr.num_test_values,
        },
    )

rvv_arithmetic_template = rule(
    implementation = rvv_arithmetic_template_impl,
    attrs = {
        "dtype": attr.string(mandatory = True),
        "in_data_size": attr.string(mandatory = True),
        "out_data_size": attr.string(mandatory = True),
        "math_op": attr.string(mandatory = True),
        "num_operands": attr.string(mandatory = True),
        "sew": attr.string(mandatory = True),
        "sign": attr.string(mandatory = True),
        "_template": attr.label(
            default = ":rvv_arithmetic_template.cc",
            allow_single_file = True,
        ),
        "source_file": attr.output(mandatory = True),
    },
)

rvv_reduction_template = rule(
    implementation = rvv_reduction_template_impl,
    attrs = {
        "dtype": attr.string(mandatory = True),
        "in_data_size": attr.string(mandatory = True),
        "out_data_size": attr.string(mandatory = True),
        "reduction_op": attr.string(mandatory = True),
        "num_operands": attr.string(mandatory = True),
        "sew": attr.string(mandatory = True),
        "sign": attr.string(mandatory = True),
        "_template": attr.label(
            default = ":rvv_reduction_template.cc",
            allow_single_file = True,
        ),
        "source_file": attr.output(mandatory = True),
    },
)

rvv_widen_arithmetic_template = rule(
    implementation = rvv_widen_arithmetic_template_impl,
    attrs = {
        "in_dtype": attr.string(mandatory = True),
        "out_dtype": attr.string(mandatory = True),
        "math_op": attr.string(mandatory = True),
        "step_operands": attr.string(mandatory = True),
        "in_sew": attr.string(mandatory = True),
        "out_sew": attr.string(mandatory = True),
        "sign": attr.string(mandatory = True),
        "num_test_values": attr.string(mandatory = True),
        "_template": attr.label(
            default = ":rvv_widen_arithmetic_template.cc",
            allow_single_file = True,
        ),
        "source_file": attr.output(mandatory = True),
    },
)
