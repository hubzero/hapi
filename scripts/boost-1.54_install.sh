#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=boost
VERSION=1.54.0
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://downloads.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.gz
tarfilebase=boost_1_54_0
tarfilename=${tarfilebase}.tar.gz
environdir=${basedir}/environ.d
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
./bootstrap.sh --prefix=${installprefix}
./b2 install

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict BOOST_CHOICE

desc "Boost ${VERSION}"

help "Boost provides free peer-reviewed portable C++ source libraries"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend LD_LIBRARY_PATH \${location}/lib
prepend BOOST_INCLUDE \${location}/include
prepend BOOST_LIBS -L\${location}/lib

setenv BOOST_INCLUDE_DIR \${location}/include
setenv BOOST_LIB_DIR \${location}/lib

tags DEVEL
_END_
