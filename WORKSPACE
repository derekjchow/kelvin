workspace(name="kelvin_hw")

load("//rules:repos.bzl", "kelvin_repos")
kelvin_repos()

load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")
grpc_deps()

# Minimal set from grpc_extra_deps
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
protobuf_deps()
load("@build_bazel_rules_apple//apple:repositories.bzl", "apple_rules_dependencies")
apple_rules_dependencies(ignore_version_differences = False)
load("@com_google_googleapis//:repository_rules.bzl", "switched_rules_by_language")
switched_rules_by_language(
    name = "com_google_googleapis_imports",
    cc = True,
    grpc = True,
    python = True,
)
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
go_rules_dependencies()

# Scala setup
load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")
scala_config(scala_version = "2.13.11")
load("@io_bazel_rules_scala//scala:scala.bzl", "rules_scala_setup", "rules_scala_toolchain_deps_repositories")
rules_scala_setup()
rules_scala_toolchain_deps_repositories(fetch_sources = True)
load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()
load("@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")
scalatest_repositories()
scalatest_toolchain()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")
rules_proto_dependencies()
rules_proto_toolchains()

load("//rules:deps.bzl", "kelvin_deps")
kelvin_deps()

load("//rules:repos.bzl", "renode_repos")
renode_repos()

load("@rules_python//python:repositories.bzl", "python_register_toolchains")
python_register_toolchains(
    name = "python39",
    python_version = "3.9",
)

load("@python39//:defs.bzl", "interpreter")
load("@rules_python//python:pip.bzl", "pip_parse")
pip_parse(
    name = "kelvin_pip_deps",
    python_interpreter_target = interpreter,
    requirements_lock = "//external:requirements.txt",
)
load("@kelvin_pip_deps//:requirements.bzl", "install_deps")
install_deps()
