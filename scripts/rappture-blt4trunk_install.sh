#!/bin/bash

source /etc/environ.sh
use -e -r R-3.2.1
use -e -r matlab-7.12

# show commands being run
set -x

# Fail script on error.
set -e

# no uninitialized variables
set -u

pkgname=rappture
VERSION=branch_blt4_trunk-@RPREV-@RTREV
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
    -d rappture_repositories/branches-blt4_trunk \
    -o branches/blt4_trunk \
    -q branches/blt4_trunk \
    -b trunk
