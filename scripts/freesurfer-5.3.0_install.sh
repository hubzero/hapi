#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=freesurfer
VERSION=5.3.0
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=${pkgname}
tarfilename=freesurfer-Linux-centos6_x86_64-stable-pub-v${VERSION}.tar.gz
downloaduri=ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${VERSION}/${tarfilename}
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})
licensepath=$(dirname ${installdir})/extra/freesurfer/${VERSION}_nciphub_license

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

if [[ -d ${tarfilebase} ]] ; then
    # clean up previously untarred file
    rm -rf ${tarfilebase}
fi

tar xvzf ${tarfilename}

# we are installing a binary package, so there is no source to compile
if [[ -d ${pkginstalldir}/${VERSION} ]] ; then
    # remove previously installed files of the same version
    rm -rf ${pkginstalldir}/${VERSION}
fi

mv ${tarfilebase} ${pkginstalldir}/${VERSION}

# we do need to install a license
cp ${licensepath} ${pkginstalldir}/${VERSION}/.license
chmod 644 ${pkginstalldir}/${VERSION}/.license

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict FREESURFER_CHOICE

desc "FreeSurfer ${VERSION}"

help "Freesurfer is a set of automated tools for reconstruction
of the brain's cortical surface from structural MRI data, and
overlay of functional MRI data onto the reconstructed surface."

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin

setenv FREESURFER_HOME \${location}
setenv FSFAST_HOME \${location}/fsfast
setenv SUBJECTS_DIR \${location}/subjects
setenv MNI_DIR \${location}/mni


tags DEVEL
_END_
