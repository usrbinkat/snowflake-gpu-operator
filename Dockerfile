FROM quay.io/spankes/nvd-driver-base:440.64.00_1-rhcos4.4

ENV KERNEL_VERSION 4.18.0-147.8.1.el8_1.x86_64
ENV GCC_VERSION 8.3.1
ENV DRIVER_VERSION 440.64.00

RUN mkdir /tmp/nvd && \
    cd /tmp/nvd && \
    echo "Kernel version: ${KERNEL_VERSION} Driver Version: ${DRIVER_VERSION}..." && \
    dnf install -q -y elfutils-libelf.x86_64 elfutils-libelf-devel.x86_64 && \
    rm -rf /lib/modules/${KERNEL_VERSION} && \
    mkdir -p /lib/modules/${KERNEL_VERSION}/proc && \
    echo "Installing Linux kernel headers..." && \
    dnf -q -y install kernel-headers-${KERNEL_VERSION} kernel-devel-${KERNEL_VERSION} > /dev/null && \
    ln -s /usr/src/kernels/${KERNEL_VERSION} /lib/modules/${KERNEL_VERSION}/build && \
    echo "Installing Linux kernel module files..." && \
    dnf install -y -q kernel-core-${KERNEL_VERSION} --setopt=install_weak_deps=False --best --downloadonly --downloaddir=/tmp/nvd && \
    cat kernel-core-*.rpm | rpm2cpio | cpio -idm --quiet &&\
    rm ./*.rpm && \
    echo "moving modules...." && \
    mv lib/modules/${KERNEL_VERSION}/modules.* /lib/modules/${KERNEL_VERSION} && \
    mv lib/modules/${KERNEL_VERSION}/kernel /lib/modules/${KERNEL_VERSION} && \
    depmod ${KERNEL_VERSION} && \
    echo "Generating Linux kernel version string..." && \
    extract-vmlinux ./lib/modules/${KERNEL_VERSION}/vmlinuz | strings | grep -E '^Linux version' | sed 's/^\(.*\)\s\+(.*)$/\1/' > version  && \
    mv version /lib/modules/${KERNEL_VERSION}/proc && \
    yum install -q -y "gcc-${GCC_VERSION}" && \
    rm -Rf /tmp/nvd

WORKDIR /usr/src/nvidia-$DRIVER_VERSION

ENTRYPOINT [ "/usr/local/bin/nvidia-driver", "init" ]
