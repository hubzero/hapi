#! /bin/bash

# debian8, boost 1.69.0
#
# in order to install boost, ensure you set 'use' for anaconda (python3) and cmake installs
# I used debian8 anaconda-6 and cmake 3.14.something.
#
# Also must set a symlink in anaconda-6 include/ subdir to point to python3.7m/
# Name the symlink python3.7 as the 'm' suffix is not expected by boost.

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=boost
version_major=1
version_minor=69
version_micro=0
version_dot=${version_major}.${version_minor}.${version_micro}
version_underbar=${version_major}_${version_minor}_${version_micro}
basedir=/apps/share64/debian8
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${version_dot}
downloaduri=http://downloads.sourceforge.net/project/boost/boost/${version_dot}/boost_${version_underbar}.tar.gz
tarfilebase=boost_${version_underbar}
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

cat <<- _END_ > ${environdir}/${pkgname}-${version_dot}
conflict BOOST_CHOICE

desc "Boost ${version_dot}"

help "Boost provides free peer-reviewed portable C++ source libraries"

version=${version_dot}
location=${pkginstalldir}/\${version}

prepend LD_LIBRARY_PATH \${location}/lib
prepend BOOST_INCLUDE \${location}/include
prepend BOOST_LIBS -L\${location}/lib

tags DEVEL
_END_

echo "all done"
exit 0
