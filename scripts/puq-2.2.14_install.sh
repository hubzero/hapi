#! /bin/bash
#
# assumes pyttk was installed in anaconda

source /etc/environ.sh
ENVIRON_CONFIG_DIRS=/apps/share64/debian7/environ.d
use -e -r anaconda-2.3.0

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=puq
VERSION=2.2.14
svnRevision=66
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
versioninstalldir=${pkginstalldir}/${VERSION}
downloaduri=https://nanohub.org/tools/puq/svn/trunk
checkoutdir=${pkgname}-${VERSION}-src
configname=debian7


# make sure our build directory exists
if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars


# download the install script
if [[ ! -d ${checkoutdir} ]] ; then
    svn co -r ${svnRevision} --no-auth-cache ${downloaduri} ${checkoutdir}
fi


# make sure our install directory exists
if [[ ! -d ${pkginstalldir}/${VERSION} ]] ; then
    mkdir -p ${pkginstalldir}/${VERSION}
fi
cd ${pkginstalldir}/${VERSION}


# run the install script
${pkginstalldir}/tars/${checkoutdir}/make.py ${configname}


# remove some environ old scripts
rm -f env-debian7.csh env-debian7.sh


# create a use script 
if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict PUQ_CHOICE

use -e -r anaconda-2.3.0

desc "PUQ Uncertainty Quantification Tool"

help "PUQ Uncertainty Quantification Tool"

version=${VERSION}
location=${pkginstalldir}/\${version}/build-${configname}

prepend    LD_LIBRARY_PATH \${location}/lib

prepend         PYTHONPATH \${location}/bin
prepend         PYTHONPATH \${location}/lib/python2.7/site-packages
prepend         PYTHONPATH \${location}/lib64/python2.7/site-packages
prepend         PYTHONPATH \${location}/lib

prepend     C_INCLUDE_PATH \${location}/include
prepend CPLUS_INCLUDE_PATH \${location}/include

prepend               PATH \${location}/bin

setenv     MEMOSA_CONFNAME debian7

tags MATHSCI
_END_
