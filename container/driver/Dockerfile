#FROM quay.io/spankes/nvd-driver-base:440.64.00-rhcos4.4 as spankes
#FROM nvidia/driver:440.64.00-rhcos4.4 as upstream

FROM registry.access.redhat.com/ubi8/ubi:latest
ENV GCC_VERSION=8.3.1
ENV DRIVER_VERSION=440.64.00
ENV KERNEL_VERSION=4.18.0-147.8.1.el8_1.x86_64

# Copy custom nvidia-driver install/build script
COPY bin/nvidia-driver /usr/local/bin/nvidia-driver

# Create base directory tree
RUN set -ex \
     && mkdir -p \
          /tmp/nvd \
          /usr/src/nvidia-${DRIVER_VERSION} \
          /lib/modules/${KERNEL_VERSION}/proc \
    && echo


RUN set -ex \
     && echo "Kernel version: ${KERNEL_VERSION} Driver Version: ${DRIVER_VERSION}..." \
    && echo

RUN set -ex \
     && cd /tmp/nvd \
     && dnf install -qy \
          elfutils-libelf.x86_64 \
          elfutils-libelf-devel.x86_64 \
     && echo "Installing Linux kernel headers..." \
     && rm -rf /lib/modules/${KERNEL_VERSION} \
     && dnf install -qy \
          kernel-devel-${KERNEL_VERSION} \
          kernel-headers-${KERNEL_VERSION} \
     && ln -s /usr/src/kernels/${KERNEL_VERSION} /lib/modules/${KERNEL_VERSION}/build \
     && echo "Installing Linux kernel module files..." \
     && dnf install \
            -qy --best \
            --setopt=install_weak_deps=False \
            --downloadonly --downloaddir=/tmp/nvd \
          kernel-core-${KERNEL_VERSION} \
     && cat kernel-core-*.rpm \
          | rpm2cpio \
          | cpio -idm --quiet \ 
     && rm ./*.rpm \
     && echo "moving modules...." \
     && mv lib/modules/${KERNEL_VERSION}/modules.* /lib/modules/${KERNEL_VERSION} \
     && mv lib/modules/${KERNEL_VERSION}/kernel /lib/modules/${KERNEL_VERSION} \
     && depmod ${KERNEL_VERSION} \
     && echo "Generating Linux kernel version string..." \
     && extract-vmlinux ./lib/modules/${KERNEL_VERSION}/vmlinuz \
          | strings \
          | grep -E '^Linux version' \
          | sed 's/^\(.*\)\s\+(.*)$/\1/' > version \
     && mv version /lib/modules/${KERNEL_VERSION}/proc \
     && dnf install -qy \
          gcc-${GCC_VERSION} \
     && dnf update -y --security \
     && dnf clean all \
     && rm -Rf /tmp/nvd \
    && echo

WORKDIR /usr/src/nvidia-${DRIVER_VERSION}
ENTRYPOINT [ "/usr/local/bin/nvidia-driver", "init" ]
