#!/bin/bash

# this depends on haing the following debian packages installed
# python-scipy
# python-numpy
# python-setuptools
# swig
# 

set -e
set -x


pkgname=pydstool
VERSION=0.88
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=http://github.org/robclewley/${pkgname}/archive/master.zip
tarfilename=master.zip
tarfilebase=pydstool-master
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

PYTHON_VERSION=2.7
PYDSTOOL_SITEPACKAGES=${installprefix}/lib/python${PYTHON_VERSION}/site-packages
PYTHONPATH=${PYDSTOOL_SITEPACKAGES}:${PYTHONPATH}

export PYTHONPATH

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

rm -rf ${tarfilebase}
unzip ${tarfilename}
cd ${tarfilebase}

# configure and install

mkdir -p ${PYDSTOOL_SITEPACKAGES}
python${PYTHON_VERSION} setup.py install --prefix=${installprefix}

# copy the examples

cp -r ${tarinstalldir}/${tarfilebase}/examples ${installprefix}/.


# create the use script

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict PYDSTOOL_CHOICE

desc "PyDSTool"

help "PyDSTool is a sophisticated & integrated simulation and analysis environment for dynamical systems models of physical systems (ODEs, DAEs, maps, and hybrid systems)."

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PYTHONPATH \${location}/lib/python${PYTHON_VERSION}/site-packages

tags DEVEL
_END_
