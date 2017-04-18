#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=convert3d
VERSION=nightly
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://downloads.sourceforge.net/project/c3d/c3d/Nightly/c3d-nightly-Linux-x86_64.tar.gz
tarfilebase=c3d-${VERSION}-Linux-x86_64
tarfilename=${tarfilebase}.tar.gz
untarfilebase=c3d-1.0.0-Linux-x86_64
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
rm -rf ${tarfilebase}
tar xvzf ${tarfilename}

mkdir -p ${installprefix}
cp -r ${untarfilebase}/bin ${installprefix}

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict CONVERT3D_CHOICE

desc "Convert3D ${VERSION}"

help "C3D is a command-line tool for converting 3D images
between common file formats."


version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin


tags MATHSCI
_END_
