#!/bin/bash

# Install elrepo
yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
# Install new kernel
yum -y --enablerepo elrepo-kernel install kernel-ml

# Make and install the kernel from sources.
# Install absent packages.
yum -y install ncurses-devel bc openssl-devel elfutils-libelf-devel make gcc flex bison perl tar
# Unpack kernel sources and go into that folder.
cd /usr/src/kernels/
curl -o linux-5.15.86.tar.xz https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.86.tar.xz
tar xf linux-5.15.86.tar.xz && cd linux-5.15.86/
# Copying config from 6-th version of kernel and run configure stage of build process.
cp /boot/config-6.*.el8.elrepo.x86_64 .config
make olddefconfig
# Make and install kernel and modules.
make -j 2
make modules_install
make install
# Reboot VM
shutdown -r now
