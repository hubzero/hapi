#! /bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=matlab_mcr
VERSION=R2014b
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://www.mathworks.com/supportfiles/downloads/R2014b/deployment_files/R2014b/installers/glnxa64/MCR_R2014b_glnxa64_installer.zip
tempinstalldir=${tarinstalldir}/tmp_install
tarfilename=MCR_R2014b_glnxa64_installer.zip
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
rm ${tempinstalldir} -rf
if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict MATLAB_MCR_CHOICE

desc "MATLAB MCR ${VERSION}"

help "http://www.mathworks.com/products/compiler/mcr/"

version=${VERSION}
location=${pkginstalldir}/\${version}/v84

prepend LD_LIBRARY_PATH \${location}/runtime/glnxa64:\${location}/bin/glnxa64:\${location}/sys/os/glnxa64

setenv XAPPLRESDIR \${location}/X11/app-defaults

tags DEVEL
_END_
