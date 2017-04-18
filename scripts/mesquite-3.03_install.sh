#!/bin/bash

# this depends on having the following debian packages installed
# 

set -e
set -x

pkgname=mesquite
VERSION=3.03
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=https://github.com/MesquiteProject/MesquiteCore/releases/download/3.03/Mesquite303_Linux.tgz
tarfilename=Mesquite303_Linux.tgz
tarfilebase=Mesquite_Folder
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
tar xf ${tarfilename}
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
conflict MESQUITE_CHOICE

desc "Mesquite ${VERSION}"

help "Mesquite is modular, extendible software for evolutionary biology, designed to help biologists organize and analyze comparative data about organisms."

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend MESQUITEPATH \${location}

tags DEVEL
_END_
