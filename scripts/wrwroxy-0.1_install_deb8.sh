#!/bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=wrwroxy
VERSION=0.1
basedir=/apps/share64/debian8
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilename=${pkgname}_v${VERSION}.tar.gz
tarfilebase=${pkgname}-${pkgname}_v${VERSION}
downloaduri=https://github.com/codedsk/${pkgname}/archive/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

rm -rf ${installprefix}
mkdir -p ${installprefix}

tar xvzf ${tarfilename}
install --mode 755 -D ${tarfilebase}/wrwroxy.py ${installprefix}/wrwroxy


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict WRWROXY_CHOICE

desc "Weber ReWrite pROXY - a rewrite proxy for weber applications on HUBzero"

help "https://github.com/codedsk/${pkgname}"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}

tags DEVEL
_END_
