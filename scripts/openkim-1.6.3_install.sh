#!/bin/bash

set -e
set -x

pkgname=openkim
VERSION=1.6.3
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=kim-api-v${VERSION}
tarfilename=${tarfilebase}.tgz
downloaduri=http://s3.openkim.org/kim-api/${tarfilename}
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
scriptdir=$(dirname ${script})
extradir=$(dirname ${scriptdir})/extra/${pkgname}/${VERSION}
patchfile=${extradir}/kim-api.patch
cpucount=`cat /proc/cpuinfo | grep processor | wc -l`

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

rm -rf ${tarfilebase}
tar xvzf ${tarfilename}
cd ${tarfilebase}


# apply patches
patch -p1 -i ${patchfile}

# create makefile
cp Makefile.KIM_Config.example Makefile.KIM_Config
sed -e "s|KIM_DIR = \$(HOME)/kim-api-vX.X.X|KIM_DIR = ${tarinstalldir}/${tarfilebase}|" \
    -e "s|#prefix =|prefix = ${installprefix}|" \
    -i Makefile.KIM_Config

# compile
make add-examples
make
make install


# create the use script
if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/openkim-${VERSION}
conflict OPENKIM_CHOICE

desc "Knowledgebase of Interatomic Models."

help "An online resource for standardized testing and long-term warehousing of interatomic models and data. This includes the development of application programming interface (API) standards for coupling atomistic simulation codes and interatomic potential subroutines. https://openkim.org"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend            PATH \${location}/bin
prepend LD_LIBRARY_PATH \${location}/lib

setenv OPENKIM_PATH \${location}

tags DEVEL
_END_
