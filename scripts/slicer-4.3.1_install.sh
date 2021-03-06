#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=slicer
VERSION=4.3.1
VERSIONSHORT=4.3
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
zipfilename=master-431.zip
zipdirbase=Slicer-master-431
downloaduri=https://github.com/Slicer/Slicer/archive/${zipfilename}
qmakepath=${basedir}/qt/4.7.4/bin/qmake
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})
cpucount=`cat /proc/cpuinfo | grep processor | wc -l`

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${zipfilename} ]] ; then
    wget ${downloaduri}
fi
rm -rf ${zipdirbase}
unzip ${zipfilename}
cd ${zipdirbase}

rm -rf ${installprefix}
mkdir ${installprefix}
cd ${installprefix}

# configure and compile
#     -DCMAKE_INSTALL_PREFIX:PATH=${installprefix} \
# cmake ../${zipdirbase} \

cmake ${pkginstalldir}/tars/${zipdirbase} \
    -DQT_QMAKE_EXECUTABLE:FILEPATH=${qmakepath}

make
# make -j4
# make install

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict SLICER_CHOICE

desc "Slicer ${VERSION}"

help "a free, comprehensive software platform for medical image analysis and
visualization developed with NIH support"

version=${VERSION}
location=${pkginstalldir}/\${version}/Slicer-build

setenv SLICER_ROOT \${location}

prepend PATH \${location}/bin
prepend PATH \${location}/lib/Slicer-${VERSIONSHORT}/cli-modules

prepend LD_LIBRARY_PATH \${location}/lib
prepend LD_LIBRARY_PATH \${location}/lib/Slicer-${VERSIONSHORT}
prepend LD_LIBRARY_PATH \${location}/lib/Slicer-${VERSIONSHORT}/cli-modules


tags MATHSCI
_END_
