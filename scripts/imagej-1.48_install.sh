#!/bin/bash

# this depends on having the following debian packages installed
# 

set -e
set -x

pkgname=imagej
VERSION=1.48
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://imagej.nih.gov/ij/download/zips/ij148.zip
tarfilename=ij148.zip
tarfilebase=ImageJ
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
    wget ${downloaduri}
fi

rm -rf ${tarfilebase}
unzip ${tarfilename}
cd ${tarfilebase}

# copy

cp -r * ${installprefix}

# cleanup

cd ..
rm -rf ${tarfilebase}

# create the use script

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict IMAGEJ_CHOICE

desc "ImageJ ${VERSION}"

help "ImageJ is a public domain Java image processing program inspired by NIH Image for the Macintosh."

version=${VERSION}
location=${pkginstalldir}/\${version}

declare -x IMAGEJPATH="${installprefix}"

tags DEVEL
_END_
