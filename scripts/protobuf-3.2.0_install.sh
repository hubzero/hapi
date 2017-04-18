#! /bin/bash

# show commands being run
set -x

source /etc/environ.sh

# Fail script on error.
set -e


pkgname=protobuf
VERSION=3.2.0
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=${pkgname}-${VERSION}
tarfilename=v${VERSION}.tar.gz
downloaduri=https://github.com/google/protobuf/archive/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
tar xvzf ${tarfilename}
cd ${tarfilebase}

./autogen.sh

./configure \
    --prefix=${installprefix}

make -j -l6
make check
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict PROTOBUF_CHOICE

desc "Protocol buffers are a language-neutral, platform-neutral extensible mechanism for serializing structured data."

help "https://developers.google.com/protocol-buffers/"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv PROTOBUF_INCLUDE_DIR \${location}/include
setenv PROTOBUF_LIB_DIR \${location}/lib

prepend PATH \${location}/bin
prepend LD_LIBRARY_PATH \${location}/lib

tags DEVEL
_END_
