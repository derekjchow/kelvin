FROM rockylinux:8

RUN dnf update -y
RUN dnf --enablerepo=devel install -y git wget unzip zip java-11-openjdk-devel.x86_64 gcc gcc-c++ make python3.12-devel cmake ninja-build gcc-toolset-13
RUN echo "source scl_source enable gcc-toolset-13"
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk"

RUN mkdir /bazel
RUN (cd /bazel && wget https://github.com/bazelbuild/bazel/releases/download/6.5.0/bazel-6.5.0-dist.zip && unzip bazel-6.5.0-dist.zip && EXTRA_BAZEL_ARGS="--tool_java_runtime_version=local_jdk" bash ./compile.sh)
env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/bazel/output

RUN git clone https://opensecura.googlesource.com/hw/kelvin
