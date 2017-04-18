#!/bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=openrefine
VERSION=2.6
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilename=${pkgname}-linux-${VERSION}-beta.1.tar.gz
tarfilebase=${pkgname}-${VERSION}-beta.1
downloaduri=https://github.com/OpenRefine/OpenRefine/releases/download/2.6-beta.1/${pkgname}-linux-${VERSION}-beta.1.tar.gz
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

cp -Rf ${tarfilebase}/* ${installprefix}

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict OPENREFINE_CHOICE

desc "Settings to launch OpenRefine."

help "https://github.com/OpenRefine"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}

tags DEVEL
_END_
