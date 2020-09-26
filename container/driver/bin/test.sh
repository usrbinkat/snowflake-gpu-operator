#!/bin/bash -x
DRIVER_VERSION=440.64.00
KERNEL_VERSION=4.18.0-193.19.1.el8_2.x86_64
GCC_VERSION=8.3.1 

# uname -a
# rpm -q gcc
dnf install gcc make

mkdir -p /usr/src/nvidia-440.64.00/kernel /run/nvidia /root/nvd \
  && cd /root/nvd

curl -LO https://raw.githubusercontent.com/CodeSparta/snowflake-gpu-operator/master/container/driver/bin/nvidia-driver \
  && chmod +x nvidia-driver 

/bin/bash -x ./nvidia-driver init

