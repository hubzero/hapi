#!/bin/bash

# show commands being run
set -x

. /etc/environ.sh
ENVIRON_CONFIG_DIRS=/apps/share64/debian7/environ.d

use -e -r eigen-2.0.16
use -e -r wxwidgets-2.8.12

# Fail script on error.
set -e

pkgname=openbabel
version=2.3.2
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${version}
tarfilename=${pkgname}-${version}.tar.gz
tarfilebase=${pkgname}-${version}
downloaduri=https://downloads.sourceforge.net/project/openbabel/openbabel/${version}/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

rm -rf ${installprefix}
mkdir -p ${installprefix}

tar xvzf ${tarfilename}

cd ${tarfilebase}
rm -rf buildOB
mkdir  buildOB
cd     buildOB

cmake ../ \
    -DCMAKE_INSTALL_PREFIX=${installprefix} \
    -DEIGEN2_INCLUDE_DIR=${EIGEN_INCLUDE}

make
make install

cd ../

rm -rf buildOB
rm -rf openbabel-${version}
cat <<- _END_ > ${environdir}/${pkgname}-${version}

conflict OPENBABEL_CHOICE

desc "The Open Source Chemistry Toolbox - Open Babel is a chemical toolbox designed to speak the many languages of chemical data. It's an open, collaborative project allowing anyone to search, convert, analyze, or store data from molecular modeling, chemistry, solid-state materials, biochemistry, or related areas."

help "http://openbabel.org"

version=${version}

prepend             PATH ${installprefix}/bin

prepend  LD_LIBRARY_PATH ${installprefix}/lib
prepend     LIBRARY_PATH ${installprefix}/lib

setenv OPENBABEL_INCLUDE ${installprefix}/include/openbabel-2.0
setenv     OPENBABEL_LIB ${installprefix}/lib

tags MATHSCI

_END_
