#! /bin/bash

# this script dies with memory allocation errors on qubeshub debian 7 containers

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=cmake
VERSION=3.7.2
basedir=/apps/share64/debian8
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilename=${pkgname}-${VERSION}.tar.gz
tardirbase=${pkgname}-${VERSION}
downloaduri=https://cmake.org/files/v3.7/${tarfilename}
environdir=${basedir}/environ.d
cpucount=`cat /proc/cpuinfo | grep processor | wc -l`

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri} -v -O ${tarfilename}
fi
rm -rf ${tardirbase}
tar xvzf ${tarfilename}
cd ${tardirbase}

./bootstrap --prefix=${installprefix}
make -j${cpucount}
make install


if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict CMAKE_CHOICE

desc "CMAKE ${VERSION}"

help "the cross-platform, open-source build system"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin

tags MATHSCI
_END_
