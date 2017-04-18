#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=cmake
VERSION=2.8.11.2
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilename=${pkgname}-${VERSION}.tar.gz
tardirbase=${pkgname}-${VERSION}
downloaduri=http://www.cmake.org/files/v2.8/${tarfilename}
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

./bootstrap
make -j${cpucount}

rm -rf ${installprefix}
mkdir -p ${installprefix}/bin

for tool in cmake ccmake ctest cpack; do
    cp ${tarinstalldir}/${tardirbase}/bin/${tool} ${installprefix}/bin/${tool};
done


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
