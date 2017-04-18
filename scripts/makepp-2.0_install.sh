#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=makepp
VERSION=2.0
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=${pkgname}-${VERSION}
tarfilename=${tarfilebase}.tgz
downloaduri=http://iweb.dl.sourceforge.net/project/makepp/2.0/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    curl ${downloaduri} > ${tarfilename}
fi
tar xvzf ${tarfilename}
cd ${tarfilebase}
./configure --prefix=${installprefix}
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict MAKEPP_CHOICE

desc "Compatible but reliable and improved replacement for make"

help "http://makepp.sourceforge.net/"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin
prepend MANPATH \${location}/man

tags DEVEL
_END_
