#!/bin/bash

set -e
set -x

pkgname=nanowhim
basedir=/apps/share/debian7
pkginstalldir=${basedir}/${pkgname}
downloaduri=https://nanohub.org:/infrastructure/nanowhim/svn/trunk

mkdir -p ${pkginstalldir}
cd ${pkginstalldir}

# this requires a login
revision=$(svn info ${downloaduri} | grep "Revision:" | cut -d ":" -f 2 | tr -d ' ')

revisiondir="r${revision}"

if [[ -d ${revisiondir} ]] ; then
    rm -rf ${revisiondir};
fi

svn checkout ${downloaduri} ${revisiondir}

rm -f current invoke_app
ln -s ${revisiondir} current
ln -s current/middleware/invoke_app
