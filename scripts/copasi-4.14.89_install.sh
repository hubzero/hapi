#! /bin/bash
# install the packages: libqt4-opengl-dev and libqwtplot3d-qt4-dev before running this script.
# show commands being run
set -x

# Fail script on error.
set -e

pkgname=copasi
VERSION=4.14.89
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=https://github.com/copasi/COPASI/releases/download/Build-89/${tarfilename}
tarfilebase=COPASI-${VERSION}-Source
tarfilename=${tarfilebase}.tar.gz
downloaduri=https://github.com/copasi/COPASI/releases/download/Build-89/${tarfilename}
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})
dependenciesdir=${tarinstalldir}/copasi-dependencies
dependenciesuri=https://github.com/copasi/copasi-dependencies/
if [[ ! -d ${tarinstalldir} ]] ; then
    mkdir -p ${tarinstalldir}
fi

if [[ ! -d ${pkginstalldir}/${VERSION} ]] ; then
    mkdir -p ${pkginstalldir}/${VERSION}
fi

cd ${tarinstalldir}

if [[ ! -e ${tarfilename} ]] ; then
    curl -LO ${downloaduri}
fi
tar xvzf ${tarfilename}
#install dependencies
if [[ ! -d ${dependenciesdir} ]]; then
    git clone ${dependenciesuri}
fi

cd ${dependenciesdir}
# createLinux.sh returns with value of 1, so including the following line
echo "echo Dependencies Successfully installed." >> createLinux.sh
./createLinux.sh
cd ..
rm -rf build_copasi
mkdir -p build_copasi
cd build_copasi

cmake -DBUILD_GUI=ON \
      -DCMAKE_INSTALL_PREFIX=${pkginstalldir}/${VERSION} \
      -DCOPASI_DEPENDENCY_DIR=../copasi-dependencies/bin \
      ../${tarfilebase}

make
make install
cd ..
rm -rf ${tarfilebase}
rm -rf build_copasi
rm -rf ${dependenciesdir}

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi
cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict COPASI_CHOICE

desc "COPASI ${VERSION}"

help "http://copasi.org"

version=${VERSION}

location=${pkginstalldir}/\${version}

setenv COPASIDIR \${location}

prepend PATH \${location}/bin
tags DEVEL
_END_
