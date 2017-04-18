#! /bin/bash
# show commands being run
set -x

# Fail script on error.
set -e

pkgname=cilk
VERSION=4.8.1
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=https://www.cilkplus.org/sites/default/files/cilk-gcc-compiler
tarfilebase=cilkplus-4_8-install
tarfilename=${tarfilebase}.tar_0.bz2
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi

if [[ ! -d ${installprefix} ]] ; then
   mkdir -p ${installprefix}
fi

cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    curl -LO ${downloaduri}/${tarfilename}
fi

tar xvf ${tarfilename} -C ${installprefix} --strip-components=1

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict CLIK_CHOICE 

desc "The Cilk++ language extends C++ to simplify writing parallel applications that efficiently exploit multiple processors."

help "http://software.intel.com/en-us/articles/download-intel-cilk-sdk"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin
prepend MANPATH \${location}/man

tags DEVEL
_END_

