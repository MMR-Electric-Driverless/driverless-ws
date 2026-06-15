# =============================================================================
# Yocto (nanbield / 4.3) build container for mmr-kria-os
# Base: Ubuntu 22.04 — the officially supported host for nanbield, and the
# last release shipping libtinfo5 (required by Xilinx XSCT).
# =============================================================================
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# --- Yocto nanbield required host packages + Xilinx extras -------------------
# (gettext-base provides `envsubst`, used by the repo's `setupsdk` script;
#  libtinfo5/xvfb/x11-utils/dbus-x11 come from apt_depencencies.txt — needed
#  by xsct/Vivado tooling pulled in by meta-xilinx-tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential chrpath cpio debianutils diffstat file gawk gcc git \
        iputils-ping libacl1 liblz4-tool locales python3 python3-git \
        python3-jinja2 python3-pexpect python3-pip python3-subunit socat \
        texinfo unzip wget xz-utils zstd bzip2 \
        gettext-base ca-certificates curl openssh-client \
        libtinfo5 xvfb x11-utils dbus-x11 \
        sudo nano vim less tmux \
    && rm -rf /var/lib/apt/lists/*

# --- Locale (BitBake hard-requires a UTF-8 locale) ---------------------------
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# --- Non-root user (BitBake refuses to run as root) --------------------------
# UID/GID are passed from .env so files on the bind mount belong to your
# host user instead of root.
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} yocto \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash yocto \
    && echo "yocto ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/yocto \
    && chmod 0440 /etc/sudoers.d/yocto

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER yocto
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
