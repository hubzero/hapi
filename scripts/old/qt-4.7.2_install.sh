#!/bin/bash

# show commands being run
set -x

# Fail script on error.
set -e


# you probably need to:
# umask 0022

VERSION=4.7.2
INSTALLDIR=/apps/qt/${VERSION}
ENVIRONDIR=/apps/environ

if [[ ! -d tars ]] ; then
    mkdir tars
fi
cd tars
if [[ ! -e qt-everywhere-opensource-src-${VERSION}.tar.gz ]] ; then
    wget http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-${VERSION}.tar.gz
fi
#gunzip qt-everywhere-opensource-src-${VERSION}.tar.gz
#tar xvf qt-everywhere-opensource-src-${VERSION}.tar
tar xvzf qt-everywhere-opensource-src-${VERSION}.tar.gz
cd qt-everywhere-opensource-src-${VERSION}

cat <<- _END_ > commands
o
yes
_END_

./configure --prefix=${INSTALLDIR} < commands
make
make install
cd ../../

cat <<- _END_ > ${ENVIRONDIR}/qt-${VERSION}
conflict QT_CHOICE

desc "The Qt GUI application framework."

help ""

version=${VERSION}
location=${INSTALLDIR}

prepend            PATH \${location}/bin
prepend LD_LIBRARY_PATH \${location}/lib
prepend         MANPATH \${location}/man

tags DEVEL
_END_
