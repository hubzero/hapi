#! /bin/bash

# show commands being run
set -x

source /etc/environ.sh

# Fail script on error.
set -e


pkgname=hdf5
VERSION=1.10.0
patch=patch1
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=${pkgname}-${VERSION}-${patch}
tarfilename=${pkgname}-${VERSION}-${patch}.tar.gz
downloaduri=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.0-patch1/src/${tarfilename}
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

./configure \
    --prefix=${installprefix} \
    --enable-fortran \
    --enable-cxx

make -j -l6
make check
make install
make check-install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict HDF5_CHOICE

desc "HDF5 is a data model, library, and file format for storing and managing data"

help "https://support.hdfgroup.org/HDF5/"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv HDF5_INCLUDE_DIR \${location}/include
setenv HDF5_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib

tags DEVEL
_END_
