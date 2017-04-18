#!/bin/bash

source /etc/environ.sh
use -e -r qt-5.4.1


set -e
set -x

pkgname=qwt
VERSION=6.1.2
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://downloads.sourceforge.net/project/qwt/qwt/${VERSION}/qwt-${VERSION}.tar.bz2
tarfilebase=qwt-${VERSION}
tarfilename=${tarfilebase}.tar.bz2
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
tar xvjf ${tarfilename}
cd ${tarfilebase}

cat <<- _END_ > qwtconfig.patch
--- qwtconfig.pri       2013-01-24 11:00:37.000000000 -0500
+++ qwtconfig.pri.newpath       2013-01-24 11:09:33.000000000 -0500
@@ -19,7 +19,7 @@
 QWT_INSTALL_PREFIX = \$\$[QT_INSTALL_PREFIX]

 unix {
-    QWT_INSTALL_PREFIX    = /usr/local/qwt-\$\$QWT_VERSION
+    QWT_INSTALL_PREFIX    = ${installprefix}
     # QWT_INSTALL_PREFIX = /usr/local/qwt-\$\$QWT_VERSION-qt-\$\$QT_VERSION
 }

_END_

patch < qwtconfig.patch
qmake QT_INSTALL_PREFIX=${installprefix}
make all
make install
# cd ../../../

cat <<- _END_ > ${environdir}/qwt-${VERSION}
conflict QWT_CHOICE

desc "A graphics extension to the Qt GUI application framework."

help "Qwt is a graphics extension to the Qt GUI application framework from
Trolltech AS of Norway. It provides a 2D plotting widget and more. See
http://qwt.sourceforge.net/ for more information."

#
# Requires use of QT libraries
#
use -e -r qt-5.4.1


version=${VERSION}
location=${installprefix}

setenv QWT_INCLUDE_PATH \${location}/include
setenv QWT_LIB_PATH \${location}/lib
setenv QWT_LIB -lqwt

prepend LD_LIBRARY_PATH \${location}/lib
prepend         MANPATH \${location}/man

tags MATHSCI
_END_
