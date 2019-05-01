#! /bin/bash

source /etc/environ.sh
use -e -r qt-4.8.5

# show commands being run
set -x

# Fail script on error.
set -e


VERSION=6.0.0
BASEDIR=/apps/share64/debian7/qwt
TARSDIR=${BASEDIR}/tars
INSTALLDIR=${BASEDIR}/${VERSION}
ENVIRONDIR=/apps/share64/debian7/environ.d

if [[ ! -d ${TARSDIR} ]] ; then
    mkdir -p ${TARSDIR}
fi

cd ${TARSDIR}

if [[ ! -e qwt-${VERSION}.tar.bz2 ]] ; then
    wget -O qwt-${VERSION}.tar.bz2 http://ftp.de.debian.org/debian/pool/main/q/qwt/qwt_${VERSION}.orig.tar.bz2
fi

tar xvjf qwt-${VERSION}.tar.bz2
cd qwt-${VERSION}


cat <<- _END_ > qwtconfig.patch
--- qwtconfig.pri       2013-01-24 11:00:37.000000000 -0500
+++ qwtconfig.pri.newpath       2013-01-24 11:09:33.000000000 -0500
@@ -19,7 +19,7 @@
 QWT_INSTALL_PREFIX = \$\$[QT_INSTALL_PREFIX]

 unix {
-    QWT_INSTALL_PREFIX    = /usr/local/qwt-\$\$QWT_VERSION
+    QWT_INSTALL_PREFIX    = ${INSTALLDIR}
 }

 win32 {
_END_

patch < qwtconfig.patch
qmake QT_INSTALL_PREFIX=${INSTALLDIR}
make all
make install
# cd ../../../

cat <<- _END_ > ${ENVIRONDIR}/qwt-${VERSION}
conflict QWT_CHOICE

desc "A graphics extension to the Qt GUI application framework."

help "Qwt is a graphics extension to the Qt GUI application framework from
Trolltech AS of Norway. It provides a 2D plotting widget and more. See
http://qwt.sourceforge.net/ for more information."

version=${VERSION}
location=${INSTALLDIR}

setenv QWT_INCLUDE_PATH \${location}/include
setenv QWT_LIB_PATH \${location}/lib
setenv QWT_LIB -lqwt

prepend LD_LIBRARY_PATH \${location}/lib
prepend         MANPATH \${location}/man

tags MATHSCI
_END_

