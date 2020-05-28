#! /bin/bash

# let's try for debian8!

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=firefox
VERSION=68.8.0esr
basedir=/apps/share64/debian8
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=firefox
tarfilename=${tarfilebase}-${VERSION}.tar.bz2
downloaduri=https://ftp.mozilla.org/pub/firefox/releases/${VERSION}/linux-x86_64/en-US/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
tar xvjf ${tarfilename}

cp -r firefox ${installprefix}

# setup use script
if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict FIREFOX_CHOICE

desc "Safe and easy web browser from Mozilla."

help "https://www.mozilla.org/en-US/firefox/"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}
prepend LD_LIBRARY_PATH \${location}

tags DEVEL
_END_

echo "all done"
exit 0
