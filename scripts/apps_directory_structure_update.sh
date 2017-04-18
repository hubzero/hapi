#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

dist=debian
os_version=$(grep Linux /etc/issue | sed -e "s/.*Linux //" -e "s/\.[0-9]*//" -e "s/ .*//")
dist_version=${dist}${os_version}


# create the environ.d directories
mkdir -p /apps/environ.d
mkdir -p /apps/share/${dist_version}/environ.d
mkdir -p /apps/share64/${dist_version}/environ.d

