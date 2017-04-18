#!/bin/bash

set -e
set -x

pkgname=qt
VERSION=4.7.4
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=https://download.qt-project.org/archive/qt/4.7/qt-everywhere-opensource-src-${VERSION}.tar.gz
tarfilebase=qt-everywhere-opensource-src-${VERSION}
tarfilename=${tarfilebase}.tar.gz
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})
cpucount=`cat /proc/cpuinfo | grep processor | wc -l`

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

rm -rf ${tarfilebase}
tar xvzf ${tarfilename}
cd ${tarfilebase}

cat <<- _END_ > commands
o
yes
_END_

./configure -prefix ${installprefix} -no-webkit < commands
make -j${cpucount}
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/qt-${VERSION}
conflict QT_CHOICE

desc "The Qt GUI application framework."

help ""

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend            PATH \${location}/bin
prepend LD_LIBRARY_PATH \${location}/lib
prepend         MANPATH \${location}/man

tags DEVEL
_END_
