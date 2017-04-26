#! /bin/bash

# this needs the following debian packages:
#   libpango1.0-dev

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=jags
VERSION=4.2.0
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilebase=JAGS-${VERSION}
tarfilename=${tarfilebase}.tar.gz
downloaduri=https://downloads.sourceforge.net/project/mcmc-jags/JAGS/4.x/Source/${tarfilename}
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
./configure --prefix=${installprefix}
make clean
make
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict JAGS_CHOICE

desc "JAGS is Just Another Gibbs Sampler. It is a program for the statistical analysis of Bayesian hierarchical models by Markov Chain Monte Carlo."

help "http://mcmc-jags.sourceforge.net/"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin
prepend MANPATH \${location}/man
prepend LD_LIBRARY_PATH \${location}/lib

setenv JAGS_INCLUDE \${location}/include
setenv JAGS_LIBS \${location}/lib
setenv JAGS_HOME \${location}

tags MATHSCI
_END_
