#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=leveldb
VERSION=1.20
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=leveldb-${VERSION}
tarfilename=v${VERSION}.tar.gz
downloaduri=https://github.com/google/leveldb/archive/${tarfilename}
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

make clean
make all

# install the headers and libraries
mkdir -p ${installprefix}
cp -r out-shared ${installprefix}/lib
cp -r include ${installprefix}/include

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict LEVELDB_CHOICE

desc "LEVELDB is a fast key-value storage library written at Google that provides an ordered mapping from string keys to string values."

help "https://github.com/google/leveldb"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv LEVELDB_INCLUDE_DIR \${location}/include
setenv LEVELDB_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib

tags DEVEL
_END_
