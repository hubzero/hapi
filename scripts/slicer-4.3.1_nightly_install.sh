#! /bin/bash

# instructions from:
# https://www.slicer.org/slicerWiki/index.php/Documentation/Nightly/Developers/Build_Instructions

# show commands being run
set -x

# Fail script on error.
set -e

source /etc/environ.sh
use -e -r qt-4.8.5
use -e -r cmake-2.8.11.2

pkgname=slicer
VERSION=4.3.1-nightly
VERSIONSHORT=4.3
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
svnrepobase=http://svn.slicer.org/Slicer4/trunk
svnrepodir=Slicer
environdir=${basedir}/environ.d
cpucount=`cat /proc/cpuinfo | grep processor | wc -l`

if [[ ! -d ${tarinstalldir} ]] ; then
    mkdir -p ${tarinstalldir}
fi
cd ${tarinstalldir}

rm -rf ${svnrepodir}
svn checkout ${svnrepobase} ${svnrepodir}

#if [[ ! -e ${svnrepodir} ]] ; then
#    svn checkout ${svnrepobase} ${svnrepodir}
#else
#    cd ${svnrepodir}
#    svn update
#fi

rm -rf ${installprefix}
mkdir ${installprefix}
cd ${installprefix}

# pre-download packages that seems not to download properly by cmake
# http://slicer-devel.65872.n3.nabble.com/Python-hash-td4030403.html
wget https://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz
expected_hash='2cf641732ac23b18d139be077bd906cd'
actual_hash=`md5sum Python-2.7.3.tgz | cut -d ' ' -f 1`
if [[ "${actual_hash}" != "${expected_hash}" ]]; then
    echo "python source download hash mismatch:"
    echo "actual_hash = ${actual_hash}"
    echo "expected_hash = ${expected_hash}"
    exit
fi


# configure and compile
#     -DCMAKE_INSTALL_PREFIX:PATH=${installprefix} \
# cmake ../${zipdirbase} \

cmake ${tarinstalldir}/${svnrepodir}

make -j${cpucount}

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
