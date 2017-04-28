#! /bin/bash

# show commands being run
set -x

source /etc/environ.sh

# Fail script on error.
set -e


pkgname=atlas
VERSION=3.10.3
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=ATLAS
tarfilename=atlas${VERSION}.tar.bz2
downloaduri=https://downloads.sourceforge.net/project/math-atlas/Stable/3.10.3/${tarfilename}
lapacktarfilename=lapack-3.7.0.tgz
lapackdownloaduri=http://www.netlib.org/lapack/${lapacktarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

# download lapack sources
if [[ ! -e ${lapacktarfilename} ]] ; then
    wget ${lapackdownloaduri}
fi

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
tar xvjf ${tarfilename}
cd ${tarfilebase}

# create a temp build directory
builddir=`mktemp -d -p ./ build.XXXXX`

cd ${builddir}

#    -b 64 \
#    -Fa alg -fPIC \

../configure \
    --prefix=${installprefix} \
    --shared \
    --with-netlib-lapack-tarfile=${pkginstalldir}/tars/${lapacktarfilename}

make
make install

cd ../

# remove the temp build directory
# rm -rf ${builddir}

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict ATLAS_CHOICE

desc "The ATLAS (Automatically Tuned Linear Algebra Software) project is an ongoing research effort focusing on applying empirical techniques in order to provide portable performance. At present, it provides C and Fortran77 interfaces to a portably efficient BLAS implementation, as well as a few routines from LAPACK."

help "http://math-atlas.sourceforge.net/"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv ATLAS_INCLUDE_DIR \${location}/include
setenv ATLAS_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib

tags DEVEL
_END_
