#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=gdal
VERSION=2.1.3
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=${pkgname}-${VERSION}
tarfilename=${tarfilebase}.tar.gz
downloaduri=http://download.osgeo.org/gdal/${VERSION}/${tarfilename}
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
./configure --prefix=${installprefix}
make clean
make
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict GDAL_CHOICE

desc "A translator library for raster and vector geospatial data formats"

help "http://www.gdal.org/"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv GDAL_INCLUDE_DIR \${location}/include
setenv GDAL_LIB_DIR \${location}/lib
setenv GDAL_DATA \${location}/share/gdal

prepend LD_LIBRARY_PATH \${location}/lib
prepend PATH \${location}/bin


tags DEVEL
_END_
