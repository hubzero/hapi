#! /bin/sh

# show commands being run
set -x

# Fail script on error.
set -e


VERSION=1.14
script=$(readlink -f ${0})
installdir=$(dirname ${script})
share_version=share64
environdir=/apps/${share_version}/environ
pinstalldir=/apps/${share_version}/gsl
tarfname=gsl-${VERSION}.tar.gz
tarurl=http://mirror.anl.gov/pub/gnu/gsl/${tarfname}

if [[ ! -d ${pinstalldir} ]] ; then
    mkdir -p ${pinstalldir}
fi
cd ${pinstalldir}

if [[ ! -d tars ]] ; then
    mkdir tars
fi
cd tars
if [[ ! -e ${tarfname} ]] ; then
    wget ${tarurl}
fi
tar xvzf ${tarfname}
cd gsl-${VERSION}
./configure --prefix=${pinstalldir}/${VERSION}
make clean
make all
make install
cd ../../

cat <<- _END_ > ${environdir}/gsl-${VERSION}
conflict GSL_CHOICE

desc "The GNU scientific library environment."

help "There should be
some help about the
GSL programming
environment here."

version=${VERSION}
location=${pinstalldir}/\${version}

setenv GSL_CONFIG \${location}/bin/gsl-config

setenv GSL_INCLUDE \${location}/include
setenv GSL_LIB     \${location}/lib

prepend LD_LIBRARY_PATH \${location}/lib
prepend    LIBRARY_PATH \${location}/lib

prepend         MANPATH \${location}/man

tags MATHSCI
_END_

