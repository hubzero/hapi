#! /bin/bash

# This script is hard coded to use python 2.7 for now.

# show commands being run
set -x

source /etc/environ.sh
use -e -r cmake-3.7.2
use -e -r hdf5-1.10.0
use -e -r atlas-3.10.3
use -e -r anaconda2-4.1

# Fail script on error.
set -e


pkgname=opencv
VERSION=3.2.0
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=opencv-${VERSION}
tarfilename=${VERSION}.tar.gz
downloaduri=https://github.com/opencv/opencv/archive/${tarfilename}
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

py_prefix=`python-config --prefix`
py_lib="${py_prefix}/lib"

# create a temp build directory
olddir=`pwd`
builddir=`mktemp -d -p ./ build.XXXXX`

cd ${builddir}

cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${installprefix} \
    -D OPENCV_BUILD_3RDPARTY_LIBS=ON \
    -D BUILD_OPENEXR=ON \
    -D BUILD_JASPER=ON \
    -D BUILD_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D PYTHON2_LIBRARY="${py_lib}/libpython2.7.so" \
    -D PYTHON2_INCLUDE_DIR="${py_prefix}/include/python2.7" \
    ..

make clean
make -j -l6
make install

# notes for building the conda-opencv3 package
# for now, people can use the python bindings built from the opencv package
#conda install --yes conda-build
#git clone https://github.com/menpo/conda-opencv3
#cd conda-opencv3
#conda config --add channels menpo
#conda build conda/
#conda install ${tarinstalldir}/${tarfilename}

cd ${olddir}

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict OPENCV_CHOICE

desc "OpenCV (Open Source Computer Vision Library) is an open source computer vision and machine learning software library."

help "http://opencv.org/about.html"

version=${VERSION}
location=${pkginstalldir}/\${version}

setenv OPENCV_INCLUDE_DIR \${location}/include
setenv OPENCV_LIB_DIR \${location}/lib
setenv OPENCV_SHARE_DIR \${location}/share

prepend LD_LIBRARY_PATH \${location}/lib

prepend PYTHONPATH \${location}/lib/python2.7/site-packages

tags DEVEL
_END_
