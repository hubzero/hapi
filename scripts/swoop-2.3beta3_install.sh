#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=swoop
VERSION=2.3beta3
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=https://pharmahub.org/tools/swoop/export/4/trunk/src/tars/SWOOP-2.3beta3.zip
tarfilename=SWOOP-2.3beta3.zip
tarfilebase=SWOOP-2.3beta3
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

# uncompress the source
rm -rf ${tarfilebase}
unzip ${tarfilename}

# move the zip file to it's final install location
mv ${tarfilebase} ${installprefix}

# install the use script
if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict SWOOP_CHOICE

desc "SWOOP ${VERSION}"

help "SWOOP: OWL Ontology Editor"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin
setenv SWOOP_CLASSPATH \${location}/lib

tags DEVELOPMENT
_END_

