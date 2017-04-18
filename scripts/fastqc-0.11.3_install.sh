#!/bin/bash

# this depends on having the following debian packages installed
# 

set -e
set -x

pkgname=fastqc
VERSION=0.11.3
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.3.zip
tarfilename=fastqc_v0.11.3.zip
tarfilebase=FastQC
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
chmod 755 ${installprefix}/fastqc

# cleanup

cd ..
rm -rf ${tarfilebase}

# create the use script

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict FASTQC_CHOICE

desc "FastQC ${VERSION}"

help "A quality control tool for high throughput sequence data."

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend FASTQCPATH \${location}

tags DEVEL
_END_
