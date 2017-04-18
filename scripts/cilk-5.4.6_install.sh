#! /bin/bash
# show commands being run
# This is the MIT Version, found at http://supertech.csail.mit.edu/cilk/
set -x

# Fail script on error.
set -e

pkgname=cilk
VERSION=5.4.6
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=cilk-5.4.6
tarfilename=${tarfilebase}.tar.gz
downloaduri=http://supertech.csail.mit.edu/cilk/${tarfilename}
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
if [[ ! -e ${tarfilename} ]]; then
  curl -LO ${downloaduri}
fi

tar -zxvf ${tarfilename}
rm build_cilk -rf
mkdir build_cilk && cd build_cilk
../${tarfilebase}/configure --prefix=${installprefix} CFLAGS="-D_XOPEN_SOURCE=600 -D_POSIX_C_SOURCE=200809L"
make
make install
cd ..
rm ${tarfilebase} -rf && rm build_cilk -rf

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict CLIK_CHOICE 

desc "(MIT Version) The Cilk++ language extends C++ to simplify writing parallel applications that efficiently exploit multiple processors."

help "http://supertech.csail.mit.edu/cilk/"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin
prepend MANPATH \${location}/man
prepend CPATH \${location}/include
prepend LIBRARY_PATH \${location}/lib:/usr/lib/x86_64-linux-gnu
prepend LD_LIBRARY_PATH \${location}/lib/:/usr/lib/x86_64-linux-gnu
tags DEVEL
_END_

