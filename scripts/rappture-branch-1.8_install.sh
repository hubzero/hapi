#!/bin/bash

source /etc/environ.sh
use -e -r R-3.2.5
use -e -r matlab-7.12

# show commands being run
set -x

# Fail script on error.
set -e

# no uninitialized variables
set -u

pkgname=rappture
VERSION=branch_1.8-@RPREV-@RTREV
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
installprefix=${pkginstalldir}/${VERSION}
installscript=checkout_repos.sh
downloaduri=http://nanohub.org/infrastructure/rappture-bat/svn/trunk/buildscripts/${installscript}

# download the install script
if [[ ! -e ${installscript} ]] ; then
    curl ${downloaduri} > ${installscript}
fi

# run the install script
bash checkout_repos.sh \
    -p ${installprefix} \
    -d rappture_repositories/branches-1.8 \
    -o branches/1.8 \
    -q branches/1.8 \
    -b trunk
