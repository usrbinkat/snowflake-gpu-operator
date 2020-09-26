FROM nvidia/driver:440.64.00-rhcos4.4
COPY bin/nvidia-driver /usr/local/bin/nvidia-driver

ENV KERNEL_VERSION 4.18.0-147.8.1.el8_1.x86_64
ENV GCC_VERSION 8.3.1
ENV DRIVER_VERSION 440.64.00

WORKDIR /tmp/nvd
RUN set -x \
     && mkdir -p \
          /tmp/nvd \
          /tmp/nvd/rpm \
          /lib/modules/${KERNEL_VERSION}/proc \
     && dnf install -qy \
            --downloadonly \
            --downloaddir=/tmp/nvd/rpm \
          gcc-${GCC_VERSION} \
          elfutils-libelf.x86_64 \
          elfutils-libelf-devel.x86_64 \
          kernel-headers-${KERNEL_VERSION} \
          kernel-devel-${KERNEL_VERSION} \
     && dnf install -yq --best \
            --setopt=install_weak_deps=False \
            --downloadonly --downloaddir=/tmp/nvd \
          kernel-core-${KERNEL_VERSION} \
    && echo
