#!/bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=pegasus
VERSION=4.2.0
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilename=pegasus-binary-${VERSION}-x86_64_deb_7.tar.gz
tarfilebase=${pkgname}-${VERSION}
downloaduri=http://download.pegasus.isi.edu/wms/download/4.2/${tarfilename}

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
rm -rf ${tarfilebase}
tar xvzf ${tarfilename}
mv ${tarfilebase} ${installprefix}

PEGASUS_INSTALL=${installprefix}

pegasusPYTHON=$(${PEGASUS_INSTALL}/bin/pegasus-config --python)
pegasusPERL=$(${PEGASUS_INSTALL}/bin/pegasus-config --perl)
pegasusJAVA=$(${PEGASUS_INSTALL}/bin/pegasus-config --classpath)

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict PEGASUS_CHOICE

desc "Pegasus Workflow Management System"

help "http://pegasus.ici.edu"

setenv  PEGASUS_HOME ${PEGASUS_INSTALL}

prepend         PATH ${PEGASUS_INSTALL}/bin

prepend   PYTHONPATH ${pegasusPYTHON}
prepend      PERLLIB ${pegasusPERL}
prepend    CLASSPATH ${pegasusJAVA}

prepend      MANPATH ${PEGASUS_INSTALL}/share/man

tags DEVEL

_END_
