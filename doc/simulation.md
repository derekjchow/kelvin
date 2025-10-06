# Simulation

## VCS Support

CoralNPU supports using VCS simulator. To enable VCS support, the following
environment variables need to be set:

```
export VCS_HOME=${PATH_TO_YOUR_VCS_HOME}
export LM_LICENSE_FILE=${YOUR_LICENSE_FILE}
```

`LD_LIBRARY_PATH` and `PATH` should also be updated.

```
export LD_LIBRARY_PATH="${VCS_HOME}"/linux64/lib
export PATH=$PATH:${VCS_HOME}/bin/
```

A VCS simulation can defined with the `vcs_testbench_test` rule. For example
use in a BUILD file:

```
load("//rules:vcs.bzl", "vcs_testbench_test")

vcs_testbench_test(
    name = "foobar_tb",
    srcs = ["Foobar_tb.sv"],
    module = "Foobar_tb",
    deps = ":foobar",
)
```

By default, we disable VCS within bazel. Invoke
`bazel {build,run,test} --config=vcs` to enable VCS support.