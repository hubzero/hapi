#!/bin/bash

gcc_version=4.8
nvidia_version=384.59
nvidia_installer="NVIDIA-Linux-x86_64-${nvidia_version}.run"
nvidia_installer_url="http://us.download.nvidia.com/XFree86/Linux-x86_64/${nvidia_version}/${nvidia_installer}"


# remove any previously downloaded versions of this file.

rm -f ${nvidia_installer}


# download the nvidia drivers from:
# http://www.nvidia.com/object/unix.html
# Choose the "Latest Long Lived Branch version"

wget ${nvidia_installer_url}
chmod +x ${nvidia_installer}


# stop the X server process

sudo service render-x-server stop


# compile the code using the same version of gcc used to compile the kernel.
# check kernel header dependencies to find the correct gcc version.

sudo CC=/usr/bin/gcc-${gcc_version} ./${nvidia_installer} -sN


# start the X server process back up

sudo service render-x-server start
