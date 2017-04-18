#! /bin/bash

# needs cmake >= 2.8.12 

# show commands being run
set -x

source /etc/environ.sh
use -e -r cmake-3.7.2

# Fail script on error.
set -e


pkgname=google-gflags
VERSION=2.2.0
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=gflags-${VERSION}
tarfilename=v${VERSION}.tar.gz
downloaduri=https://github.com/gflags/gflags/archive/${tarfilename}
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

cmake \
    -DCMAKE_INSTALL_PREFIX:PATH=${installprefix} \
    -DBUILD_SHARED_LIBS=TRUE \
    -DBUILD_STATIC_LIBS=TRUE \
    -DBUILD_gflags_LIBS=TRUE

make
make install


if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict GFLAGS_CHOICE

desc "The gflags package contains a C++ library that implements commandline flags processing."

help "https://github.com/gflags/gflags"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv GFLAGS_INCLUDE_DIR \${location}/include
setenv GFLAGS_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib

tags DEVEL
_END_
