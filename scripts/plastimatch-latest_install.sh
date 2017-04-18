#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=plastimatch
VERSION=`date "+%Y%m%d"`
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=https://forge.abcd.harvard.edu/svn/plastimatch/plastimatch/trunk
svndirbase=$pkgname
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

rm -rf ${svndirbase}
svn checkout --username anonymous --password '' ${downloaduri} ${svndirbase} <<_END_
t
_END_

rm -rf build
mkdir build
cd build

# configure and compile
cmake ../${svndirbase} -DCMAKE_INSTALL_PREFIX:PATH=${installprefix}

make all
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict PLASTIMATCH_CHOICE

desc "Plastimatch ${VERSION}"

help "medical image reconstruction and registration"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin
prepend LD_LIBRARY_PATH \${location}/lib
prepend PLASTIMATCH_LIB -L\${location}/lib
prepend PLASTIMATCH_INCLUDE -I\${location}/include

tags MATHSCI
_END_
