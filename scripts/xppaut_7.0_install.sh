#!/bin/bash

set -e
set -x

pkgname=xppaut
VERSION=7.0
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://www.math.pitt.edu/~bard/bardware/${pkgname}_latest.tar.gz
tarfilebase=${pkgname}_latest
tarfilename=${tarfilebase}.tar.gz
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${tarinstalldir} ]] ; then
    mkdir -p ${tarinstalldir}
fi
cd ${tarinstalldir}

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

mkdir -p ${tarfilebase}
rm -rf ${tarfilebase}/*
tar xvf ${tarfilename} -C ${tarfilebase}
cd ${tarfilebase}

# modify configure script
sed -e 's/DESTDIR =/DESTDIR = \/apps\/share64\/debian7\/xppaut\/7.0/g' -i Makefile
sed -e 's/BINDIR = \/usr\/local\/bin/BINDIR = \/bin/g' -i Makefile
sed -e 's/DOCDIR = \/usr\/share\/doc\/xppaut/DOCDIR = \/doc\/xppaut/g' -i Makefile
sed -e 's/MANDIR = \/usr\/local\/man\/man1/MANDIR = \/man\/man1/g' -i Makefile
sed -e 's/#CFLAGS=   -g -O -m64/CFLAGS=   -g -O -m64/g' -i Makefile
sed -e 's/CFLAGS= -g -pedantic -O -m32/#CFLAGS= -g -pedantic -O -m32/g' -i Makefile
sed -e 's/LDFLAGS=  -m32/#LDFLAGS=  -m32/g' -i Makefile 
sed -e 's/#LDFLAGS=  -m64/LDFLAGS=  -m64/g' -i Makefile 

# configure and install
make
make install

# create the use script
if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict XPPAUT_CHOICE

desc "xppaut"

help "XPPAUT is a general numerical tool for simulating, animating, and analyzing dynamical systems."

version=${VERSION}
location=${installprefix}

prepend PATH ${installprefix}/bin

tags DEVEL
_END_
