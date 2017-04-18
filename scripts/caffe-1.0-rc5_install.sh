#! /bin/bash

# This script is hard coded to use python 2.7 for now.

# show commands being run
set -x

source /etc/environ.sh
use -e -r cmake-3.7.2
use -e -r hdf5-1.10.0
use -e -r atlas-3.10.3
use -e -r anaconda2-4.1
use -e -r opencv-3.2.0
use -e -r boost-1.54.0
use -e -r google-gflags-2.2.0
use -e -r google-glog-0.3.4
use -e -r leveldb-1.20
use -e -r lmdb-0.9.19
use -e -r opencv-3.2.0
use -e -r protobuf-3.2.0
use -e -r snappy-1.1.4


# Fail script on error.
set -e


pkgname=caffe
version_long=1.0-rc5
version_short=rc5
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${version_long}
tarfilebase=caffe-${version_short}
tarfilename=${version_short}.tar.gz
downloaduri=https://github.com/BVLC/caffe/archive/${tarfilename}
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

# install python requirements
cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd ..

# create a temp build directory
olddir=`pwd`
builddir=`mktemp -d -p ./ build.XXXXX`

cd ${builddir}


cmake \
    -D CPU_ONLY=1 \
    -D CMAKE_INSTALL_PREFIX=${installprefix} \
    -D GFLAGS_INCLUDE_DIR=${GFLAGS_INCLUDE_DIR} \
    -D GFLAGS_LIBRARY=${GFLAGS_LIB_DIR}/libgflags.so \
    -D GLOG_INCLUDE_DIR=${GLOG_INCLUDE_DIR} \
    -D GLOG_LIBRARY=${GLOG_LIB_DIR}/libglog.so \
    -D Protobuf_INCLUDE_DIR=${PROTOBUF_INCLUDE_DIR} \
    -D Protobuf_LIBRARY=${PROTOBUF_LIB_DIR}/libprotobuf.so \
    -D LMDB_INCLUDE_DIR=${LMDB_INCLUDE_DIR} \
    -D LMDB_LIBRARIES=${LMDB_LIB_DIR}/liblmdb.so \
    -D LevelDB_INCLUDE=${LEVELDB_INCLUDE_DIR} \
    -D LevelDB_LIBRARY=${LEVELDB_LIB_DIR}/libleveldb.so \
    -D Snappy_INCLUDE_DIR=${SNAPPY_INCLUDE_DIR} \
    -D Snappy_LIBRARIES=${SNAPPY_LIB_DIR}/libsnappy.so \
    -D OpenCV_DIR=${OPENCV_SHARE_DIR}/OpenCV \
    -D Atlas_CLAPACK_INCLUDE_DIR=${ATLAS_INCLUDE_DIR} \
    -D Atlas_CBLAS_LIBRARY=${ATLAS_LIB_DIR}/libcblas.a \
    -D Atlas_BLAS_LIBRARY=${ATLAS_LIB_DIR}/libf77blas.a \
    -D Boost_INCLUDE_DIR=${BOOST_INCLUDE_DIR} \
    -D Boost_LIBRARY_DIR_RELEASE=${BOOST_LIB_DIR} \
    ..


make clean
make -j -l6
make install

cd ${olddir}

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${version_long}
conflict CAFFE_CHOICE

desc "Deep learning framework by the BVLC."

help "http://caffe.berkeleyvision.org"

version=${version_long}
location=${pkginstalldir}/\${version}

setenv CAFFE_INCLUDE_DIR \${location}/include
setenv CAFFE_LIB_DIR \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib

prepend PYCAFFE_ROOT \${location}/python
prepend PYTHONPATH \${location}/python
prepend PATH \${location}/build/tools
prepend PATH \${location}/python

tags DEVEL
_END_
