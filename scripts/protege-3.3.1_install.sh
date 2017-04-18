#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=protege
VERSION=3.3.1
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
script=$(readlink -f ${0})
installdir=$(dirname ${script})
extradir=$(dirname ${installdir})/extra/${pkgname}/${VERSION}
patchfile=${extradir}/search_directory.patch
installfile=${extradir}/install_protege.bin

sh ${installfile} -i console -DUSER_INSTALL_DIR=${installprefix}
cd ${installprefix}
patch -p1 -i ${patchfile}
cd -

# fix world writable permissions
chmod 700 ${installprefix}/UninstallerData/.com.zerog.registry.xml

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict PROTEGE_CHOICE

desc "Protege ${VERSION}"

help "Protege is a free, open-source platform that provides a growing user
community with a suite of tools to construct domain models and knowledge-based
applications with ontologies."

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}

tags DEVEL
_END_
