#!/bin/bash

set -e
set -x

pkgname=qt
VERSION_MM=5.9
VERSION=5.9.1
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=qt-everywhere-opensource-src-${VERSION}
tarfilename=${tarfilebase}.tar.xz
downloaduri=http://download.qt.io/official_releases/qt/${VERSION_MM}/${VERSION}/single/${tarfilename}
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})
cpucount=`cat /proc/cpuinfo | grep processor | wc -l`

#if [[ ! -d ${pkginstalldir}/tars ]] ; then
#    mkdir -p ${pkginstalldir}/tars
#fi
cd ${pkginstalldir}/tars
#
#if [[ ! -e ${tarfilename} ]] ; then
#    wget ${downloaduri}
#fi
#
#rm -rf ${tarfilebase}
#tar xvJf ${tarfilename}
cd ${tarfilebase}
#
#
## remove the use of the gold linker
## using the gold linker when it is not installed will cause
## g++ to fail.
## https://bugreports.qt-project.org/browse/QTBUG-28598
##sed -i -e "/QMAKE_LFLAGS+=-fuse-ld=gold/d" \
##    src/3rdparty/webkit/Source/common.pri
#
#./configure -prefix ${installprefix} \
#            -confirm-license \
#            -opensource \
#            -qt-xcb
#
##make -j${cpucount}
#make -j8
make -j1 install

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
