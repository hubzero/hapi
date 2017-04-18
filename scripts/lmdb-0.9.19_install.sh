#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=lmdb
VERSION=0.9.19
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=lmdb-LMDB_${VERSION}
tarfilename=LMDB_${VERSION}.tar.gz
downloaduri=https://github.com/LMDB/lmdb/archive/${tarfilename}
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
cd libraries/liblmdb

# no configure script, substitute values for prefix
sed -ie "s:prefix.*=.*:prefix = ${installprefix}:" Makefile

make clean
make all
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict LMDB_CHOICE

desc "LMDB is compact, fast, powerful, and robust and implements a simplified variant of the BerkeleyDB (BDB) API."

help "https://github.com/LMDB/lmdb"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv LMDB_INCLUDE_DIR \${location}/include
setenv LMDB_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib
prepend PATH \${location}/bin

tags DEVEL
_END_
