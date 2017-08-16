#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=node
VERSION=6.11.2
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=node-v${VERSION}-linux-x64
tarfilename=${tarfilebase}.tar.xz
downloaduri=https://nodejs.org/dist/v${VERSION}/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

# extract the binaries and install them into prefix
mkdir -p ${installprefix}
tar xvJf ${tarfilename} --strip 1 --directory ${installprefix}

# setup Rlogo-1.png
install -D --mode 0444 ${installdir}/NodeJs_logo.png ${installprefix}/NodeJs_logo.png

# setup use script
if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict NODE_CHOICE

desc "Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine."

help "https://nodejs.org"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin
prepend LD_LIBRARY_PATH \${location}/lib
prepend MANPATH \${location}/share/man

setenv NODE_LOGO_PATH \${location}/node_logo.png

tags DEVEL
_END_
