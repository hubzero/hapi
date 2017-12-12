#!/bin/bash

source /etc/environ.sh

# show commands being run
set -x

# Fail script on error.
set -e

# no uninitialized variables
set -u

pkgname=rappture
VERSION=branch_blt4-@RPREV-@RTREV
basedir=/apps/share
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
# we used to use specific revisions of rappture and runtime repositories
# because those are the last known working revisions of this branch
# that were installed on ccehub and catalyzecare.
# ccehub used rappture revision 3286 and runtime revision 1683
# catalyzecare used rappture revision 3892 and runtime revision 1726
# these revisions probably won't be able to find java because the
# /usr/lib/jvm directories have changed
bash checkout_repos.sh \
    -p ${installprefix} \
    -d rappture_repositories/branches-blt4 \
    -o branches/blt4 \
    -q branches/blt4 \
    -b trunk
