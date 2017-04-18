#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=itkdicomrt
VERSION=20091023
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://www.insight-journal.org/download/sourcecode/701/5
zipfilebase=Source_itkDICOMRT_20March2013_itk3version
zipfilename=SourceCode5_Source_itkDICOMRT_20March2013_itk3version.zip
binaryname=itkDICOMRT
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})
patchdir=$(dirname ${installdir})/extras/${pkgname}/patches

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${zipfilename} ]] ; then
    wget ${downloaduri}
    mv 5 ${zipfilename}
fi

rm -rf ${zipfilebase}
unzip ${zipfilename}

rm -rf build
mkdir build
cd build

# configure and compile
cmake ../${zipfilebase} -DCMAKE_INSTALL_PREFIX:PATH=${installprefix}

make all

# there is no make install, so we install the file manually
# make install

rm -rf ${installprefix}
mkdir -p ${installprefix}/bin
install --mode 0755 -D ${binaryname} ${installprefix}/bin


if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict ITKDICOMRT_CHOICE

desc "Insight Toolkit DICOM-RT ${VERSION}"

help "Importing Contours from DICOM-RT Structure Sets."

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin

tags MATHSCI
_END_
