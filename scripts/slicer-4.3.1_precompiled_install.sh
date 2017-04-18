#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=slicer
VERSION=4.3.1
VERSIONSHORT=4.3
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilename1=153901
tarfilename2=${pkgname}-${VERSION}.tgz
tardirbase=Slicer-${VERSION}-linux-amd64
downloaduri=http://download.slicer.org/bitstream/${tarfilename1}
environdir=${basedir}/environ.d

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename2} ]] ; then
    wget ${downloaduri}
    mv ${tarfilename1} ${tarfilename2}
fi
rm -rf ${tardirbase}
tar xzf ${tarfilename2}

rm -rf ${installprefix}
mkdir ${installprefix}

mv ${tardirbase}/* ${installprefix}/.


if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict SLICER_CHOICE

desc "Slicer ${VERSION}"

help "a free, comprehensive software platform for medical image analysis and
visualization developed with NIH support"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv SLICER_ROOT \${location}

prepend PATH \${location}
prepend PATH \${location}/bin
prepend PATH \${location}/lib/Slicer-${VERSIONSHORT}/cli-modules

prepend LD_LIBRARY_PATH \${location}/lib
prepend LD_LIBRARY_PATH \${location}/lib/Slicer-${VERSIONSHORT}
prepend LD_LIBRARY_PATH \${location}/lib/Slicer-${VERSIONSHORT}/cli-modules


tags MATHSCI
_END_
