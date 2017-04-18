#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=snappy
VERSION=1.1.4
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=snappy-${VERSION}
tarfilename=${VERSION}.tar.gz
downloaduri=https://github.com/google/snappy/archive/${tarfilename}
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

./autogen.sh

./configure --prefix=${installprefix}

make clean
make all
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict SNAPPY_CHOICE

desc "Snappy, a fast compressor/decompressor."

help "https://github.com/google/snappy"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv SNAPPY_INCLUDE_DIR \${location}/include
setenv SNAPPY_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib

tags DEVEL
_END_
