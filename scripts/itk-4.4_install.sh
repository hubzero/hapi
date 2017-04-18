#! /bin/sh

# show commands being run
set -x

# Fail script on error.
set -e


pkgname=itk
VERSION=4.4.1
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
gdcmprefix=${basedir}/gdcm
vtkprefix=${basedir}/vtk
downloaduri=http://downloads.sourceforge.net/project/itk/itk/4.4/InsightToolkit-4.4.1.tar.gz
tarfilebase=InsightToolkit-${VERSION}
tarfilename=${tarfilebase}.tar.gz
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})
patchdir=$(dirname ${installdir})/extras/${pkgname}/patches

if [[ ! -d ${pkginstalldir} ]] ; then
    mkdir -p ${pkginstalldir}
fi
cd ${pkginstalldir}

if [[ ! -d tars ]] ; then
    mkdir tars
fi
cd tars
if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
tar xvzf ${tarfilename}
cd ${tarfilebase}

# apply debian package patches
for fn in `ls ${patchdir}/*.patch`; do
    patch -p1 < $fn;
done

# configure and compile
#    -DCMAKE_INSTALL_PREFIX:GDCM=${gdcmprefix} \
cmake . \
    -DCMAKE_INSTALL_PREFIX:PATH=${installprefix} \
    -DCMAKE_INSTALL_PREFIX:PATH+=${vtkprefix} \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_TESTING:BOOL=OFF \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_DOXYGEN:BOOL=OFF \
    -DCMAKE_CXX_FLAGS:STRING=-Wno-deprecated \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DITK_USE_REVIEW:BOOL=ON \
    -DITK_USE_REVIEW_STATISTICS:BOOL=ON \
    -DITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON \
    -DITK_USE_TRANSFORM_IO_FACTORIES:BOOL=ON \
    -DITK_USE_SYSTEM_GDCM:BOOL=ON \
    -DITK_USE_SYSTEM_PNG:BOOL=ON \
    -DITK_USE_SYSTEM_TIFF:BOOL=ON \
    -DITK_USE_SYSTEM_ZLIB:BOOL=ON \
    -DITK_USE_SYSTEM_VXL:BOOL=OFF \
    -DUSE_FFTWD:BOOL=ON \
    -DUSE_FFTWF:BOOL=ON \
    -DITK_USE_CONCEPT_CHECKING:BOOL=ON \
    -DITK_USE_STRICT_CONCEPT_CHECKING:BOOL=ON \
    -DUSE_WRAP_ITK:BOOL=OFF

#cmake ../InsightToolkit-3.20.1     -DCMAKE_INSTALL_PREFIX:PATH=/home/nciphub/dkearney/playground/packages/itk/3.20.1 -DCMAKE_PREFIX_PATH:PATH+=/home/nciphub/dkearney/playground/packages/vtk/6.0.0    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON     -DBUILD_EXAMPLES:BOOL=OFF     -DBUILD_SHARED_LIBS:BOOL=ON     -DBUILD_TESTING:BOOL=OFF     -DCMAKE_BUILD_TYPE:STRING=Release     -DBUILD_DOXYGEN:BOOL=OFF     -DCMAKE_CXX_FLAGS:STRING=-Wno-deprecated     -DCMAKE_SKIP_RPATH:BOOL=ON     -DITK_USE_REVIEW:BOOL=ON     -DITK_USE_REVIEW_STATISTICS:BOOL=ON     -DITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON     -DITK_USE_TRANSFORM_IO_FACTORIES:BOOL=ON     -DITK_USE_SYSTEM_GDCM:BOOL=ON     -DITK_USE_SYSTEM_PNG:BOOL=ON     -DITK_USE_SYSTEM_TIFF:BOOL=ON     -DITK_USE_SYSTEM_ZLIB:BOOL=ON     -DITK_USE_SYSTEM_VXL:BOOL=OFF     -DUSE_FFTWD:BOOL=ON     -DUSE_FFTWF:BOOL=ON     -DITK_USE_CONCEPT_CHECKING:BOOL=ON     -DITK_USE_STRICT_CONCEPT_CHECKING:BOOL=ON     -DUSE_WRAP_ITK:BOOL=OFF

make all
make install

cd ${pkginstalldir}

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict ITK_CHOICE

desc "Insight Toolkit (ITK) ${VERSION}"

help "ITK is an open-source software toolkit for performing
registration and segmentation."

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin

tags MATHSCI
_END_
