#!/bin/bash

set -e
set -x

pkgname=qt
VERSION_MM=4.6
VERSION=4.6.3
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://download.qt-project.org/archive/qt/${VERSION_MM}/qt-everywhere-opensource-src-${VERSION}.tar.gz
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

#./configure -prefix ${installprefix} -no-webkit < commands
#make -j${cpucount}
#make install

./configure -prefix ${installprefix} < commands
make
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
