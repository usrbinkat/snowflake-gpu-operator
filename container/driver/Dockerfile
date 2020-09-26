#FROM codesparta/driver:440.64.00-rhcos4.4-builder as builder
FROM localhost/spankes/nvd:builder as builder
FROM nvidia/driver:440.64.00-rhcos4.4

ENV GCC_VERSION 8.3.1
ENV DRIVER_VERSION 440.64.00
ENV KERNEL_VERSION 4.18.0-147.8.1.el8_1.x86_64

COPY --from=builder /tmp/nvd /root/nvd
COPY --from=builder /usr/local/bin/nvidia-driver /usr/local/bin/nvidia-driver
COPY --from=builder /lib/modules/${KERNEL_VERSION}/proc /lib/modules/${KERNEL_VERSION}/proc

WORKDIR /root/nvd
RUN set -x \
     && dnf install -y /root/nvd/*.rpm /root/nvd/rpm/*.rpm \
     && ln -s /usr/src/kernels/${KERNEL_VERSION} /lib/modules/${KERNEL_VERSION}/build \
     && cat kernel-core-*.rpm \
          | rpm2cpio \
          | cpio -idm --quiet \
     && mv -f lib/modules/${KERNEL_VERSION}/modules.* /lib/modules/${KERNEL_VERSION} \
     && mv -f lib/modules/${KERNEL_VERSION}/kernel /lib/modules/${KERNEL_VERSION} \
     && depmod ${KERNEL_VERSION} \
     && extract-vmlinux ./lib/modules/${KERNEL_VERSION}/vmlinuz \
          | strings \
          | grep -E '^Linux version' \
          | sed 's/^\(.*\)\s\+(.*)$/\1/' \
          | tee version \
     && mv version /lib/modules/${KERNEL_VERSION}/proc \
     && mkdir -p \
          /run/nvidia \
     && dnf clean all \
    && echo

ENTRYPOINT [ "/usr/local/bin/nvidia-driver", "init" ]
WORKDIR /usr/src/nvidia-$DRIVER_VERSION

#    && rm -rf /lib/modules/${KERNEL_VERSION} \
#    && rm ./*.rpm \
