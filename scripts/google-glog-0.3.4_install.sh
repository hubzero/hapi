#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=google-glog
VERSION=0.3.4
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=glog-${VERSION}
tarfilename=v${VERSION}.tar.gz
downloaduri=https://github.com/google/glog/archive/${tarfilename}
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
make all
# dont call "make check" because it fails when looking for test-driver
# script which i think comes with updated versions of automake
# make check
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict GLOG_CHOICE

desc "This library provides logging APIs based on C++-style streams and various helper macros."

help "https://github.com/google/glog"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv GLOG_INCLUDE_DIR \${location}/include
setenv GLOG_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib

tags DEVEL
_END_
