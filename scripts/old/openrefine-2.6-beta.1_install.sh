#!/bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=openrefine
VERSION=2.6-beta.1
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilename=${pkgname}-linux-${VERSION}.tar.gz
tarfilebase=${pkgname}-${VERSION}
downloaduri=https://github.com/OpenRefine/OpenRefine/releases/download/${VERSION}/${tarfilename}
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

desc "OpenRefine is a free, open source power tool for working with messy data and improving it "

help "http://openrefine.org"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}
setenv OPENREFINEBASE \${location}

tags DEVEL
_END_
