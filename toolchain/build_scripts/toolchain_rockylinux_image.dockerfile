# Docker container to build coralnpu_v2 toolchain in Rocky linux.
# Run at toolchain/build_scripts directory :
# docker build --no-cache -t toolchain_test -f toolchain_rockylinux_image.dockerfile .

FROM rockylinux/rockylinux:8.4

WORKDIR toolchain/build_scripts


RUN dnf upgrade -y --refresh
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager -y --set-enabled powertools
RUN dnf install -y git
#python3 is a prereq for llvm build
Run dnf install python3.9 -y
RUN dnf install -y \
                cmake \
                make \
                gcc \
                clang \
                texinfo \
                bison \
                flex \
                bzip2 \
                ninja-build \
                zlib-devel \
                lld \
                autoconf \
                automake \
                libmpc-devel \
                mpfr-devel \
                gmp-devel \
                gawk \
                patchutils \
                gcc-c++ \
                zlib-devel \
                libslirp-devel \
                expat-devel

RUN git config --global user.name "Foo Bar"
RUN git config --global user.email "foo@bar.com"