#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=netlogo
VERSION=5.1.0
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=https://ccl.northwestern.edu/netlogo/${VERSION}/
tarfilebase=${pkgname}-${VERSION}
tarfilename=${tarfilebase}.tar.gz
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi

if [[ ! -d ${pkginstalldir}/${VERSION} ]]; then
    mkdir -p ${pkginstalldir}/${VERSION} 
fi

cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
   wget ${downloaduri}/${tarfilename}
fi
rm -rf ${tarfilebase}
tar zxvf ${tarfilename} -C ../${VERSION} --strip-components 1

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict NETLOGO_CHOICE

desc "NetLogo ${VERSION}"

help "Multi-agent programmable modeling environment.
https://ccl.northwestern.edu/netlogo"
version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}
tags DEVEL
_END_


