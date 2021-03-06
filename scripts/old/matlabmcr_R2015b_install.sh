#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=matlab_mcr
VERSION=R2015b
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tempinstalldir=${tarinstalldir}/tmp_install
tarfilename=MCR_${VERSION}_glnxa64_installer.zip
downloaduri=https://www.mathworks.com/supportfiles/downloads/${VERSION}/deployment_files/${VERSION}/installers/glnxa64/${tarfilename}
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi

if [[ ! -d ${installprefix} ]] ; then
   mkdir -p ${installprefix}
fi

cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
   wget ${downloaduri}
fi
rm -rf ${tempinstalldir}
mkdir ${tempinstalldir}
unzip ${tarfilename} -d ${tempinstalldir}
cd ${tempinstalldir}
./install -mode silent -destinationFolder ${installprefix} -agreeToLicense yes
rm -rf ${tempinstalldir}
if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict MATLAB_MCR_CHOICE

desc "MATLAB MCR ${VERSION}"

help "http://www.mathworks.com/products/compiler/mcr/"

version=${VERSION}
location=${pkginstalldir}/\${version}/v90

prepend LD_LIBRARY_PATH \${location}/runtime/glnxa64:\${location}/bin/glnxa64:\${location}/sys/os/glnxa64

setenv XAPPLRESDIR \${location}/X11/app-defaults

tags DEVEL
_END_
