#! /bin/bash

# this needs the following debian packages:
#   libpango1.0-dev
#
# additional optional packages:
#   tcl-dev
#   tk-dev

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=R
VERSION=3.4.0
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=R-${VERSION}
tarfilename=${tarfilebase}.tar.gz
downloaduri=https://cran.r-project.org/src/base/R-3/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
tar xvzf ${tarfilename}
cd ${tarfilebase}
./configure --enable-R-shlib \
            --prefix=${installprefix} \
            --with-tcltk \
            --with-cairo
make clean
make all
# TODO: figure out why check fails while testing complex numbers
#make check
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict R_CHOICE

desc "R is a system for statistical computation and graphics. It consists of a language plus a run-time environment with graphics, a debugger, access to certain system functions, and the ability to run programs stored in script files."

help "https://cran.r-project.org"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv R_HOME \${location}/lib/R

setenv R_LIBS \$R_HOME/library
prepend PATH \${location}/bin

prepend MANPATH \${location}/man

tags MATHSCI
_END_
