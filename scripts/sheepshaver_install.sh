#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=SheepShaver
VERSION=GCC44_SDL_Unix
release=29-07-2013
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=${pkgname}_${VERSION}_${release}
tarfilename=${tarfilebase}.zip
downloaduri=http://www.open.ou.nl/hsp/downloads/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
unzip ${tarfilename} -d ${installprefix}

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict SheepShaver_CHOICE

desc "SheepShaver is a MacOS run-time environment for BeOS and Linux that allows you to run classic MacOS applications inside the BeOS/Linux multitasking environment."

help "http://sheepshaver.cebix.net"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/

tags MATHSCI
_END_

