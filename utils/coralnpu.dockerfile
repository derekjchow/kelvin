# Dockerfile to create a stable CoralNPU build environment
#
# Build command:
# docker build -t coralnpu -f utils/coralnpu.dockerfile .
#
# Run command:
# docker run -it coralnpu /bin/bash

FROM debian:bookworm AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ARG _UID=1000
ARG _GID=1000
ARG _USERNAME=builder
ENV HOME=/home/${_USERNAME}

RUN ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes && \
    apt-get update && \
    apt-get install -y -qq \
        apt-transport-https \
        autoconf \
        build-essential \
        ca-certificates \
        ccache \
        curl \
        fuse3 \
        gawk \
        git \
        gnupg \
        libmpfr-dev \
        lsb-release \
        python-is-python3 \
        python3 \
        python3-pip \
        srecord \
        sudo \
        tzdata \
        unzip \
        xxd \
        zip && \
    update-ca-certificates && \
    curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > /tmp/bazel-archive-keyring.gpg && \
    mv /tmp/bazel-archive-keyring.gpg /usr/share/keyrings/ && \
    echo "deb [arch=$(dpkg-architecture -q DEB_HOST_ARCH) signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list && \
    apt update && \
    apt install bazel bazel-6.2.1 && \
    echo "${_USERNAME} ALL=(ALL) NOPASSWD:/usr/bin/apt" >> /etc/sudoers.d/${_USERNAME} && \
    echo "${_USERNAME} ALL=(ALL) NOPASSWD:/bin/mkdir" >> /etc/sudoers.d/${_USERNAME} && \
    echo "${_USERNAME} ALL=(ALL) NOPASSWD:/bin/chown" >> /etc/sudoers.d/${_USERNAME} && \
    echo "${_USERNAME} ALL=(ALL) NOPASSWD:/bin/ln" >> /etc/sudoers.d/${_USERNAME} && \
    echo "${_USERNAME} ALL=(ALL) NOPASSWD:/usr/bin/xargs" >> /etc/sudoers.d/${_USERNAME} && \
    addgroup --gid ${_GID} ${_USERNAME} && \
    adduser \
        --home ${HOME} \
        --disabled-password \
        --gecos "" \
        --uid ${_UID} \
        --gid ${_GID} \
        ${_USERNAME} && \
    chown ${_USERNAME}:${_USERNAME} ${HOME}
# Work around differeing libmpfr versions between distros
RUN ln -sf /lib/x86_64-linux-gnu/libmpfr.so.6.2.0 /lib/x86_64-linux-gnu/libmpfr.so.4
USER ${_USERNAME}
WORKDIR /home/${_USERNAME}/
RUN git clone https://github.com/google-coral/coralnpu.git
