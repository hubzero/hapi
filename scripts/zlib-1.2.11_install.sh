#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=zlib
VERSION=1.2.11
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=zlib-${VERSION}
tarfilename=${tarfilebase}.tar.gz
downloaduri=http://zlib.net/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
tar xvzf ${tarfilename}
cd ${tarfilebase}
./configure --prefix=${installprefix}
make clean
make
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict ZLIB_CHOICE

desc "A Massively Spiffy Yet Delicately Unobtrusive Compression Library
(Also Free, Not to Mention Unencumbered by Patents)"

help "http://zlib.net/"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv ZLIB_INCLUDE_DIR \${location}/include
setenv ZLIB_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib


tags DEVEL
_END_
