#! /bin/sh

# show commands being run
set -x

# Fail script on error.
set -e


VERSION=3.2.4
script=$(readlink -f ${0})
installdir=$(dirname ${script})


if [[ ! -d /apps/octave ]] ; then
    mkdir -p /apps/octave
fi
cd /apps/octave

if [[ ! -d tars ]] ; then
    mkdir tars
fi
cd tars
if [[ ! -e octave-${VERSION}.tar.gz ]] ; then
    wget ftp://ftp.gnu.org/gnu/octave/octave-${VERSION}.tar.gz

fi
tar xvzf octave-${VERSION}.tar.gz
cd octave-${VERSION}
./configure --prefix=/apps/octave/${VERSION}
make clean
make all
make install
cd ../../

if [[ ! -d /apps/environ ]] ; then
    mkdir /apps/environ
fi

cat <<- _END_ > /apps/environ/octave-${VERSION}
conflict OCTAVE_CHOICE

desc "Octave ${VERSION}"

help "OCTAVE is a numerical computing environment
and programming language. It allows for easy matrix
manipulation."

version=${VERSION}
location=/apps/octave/\${version}

prepend PATH \${location}/bin

tags MATHSCI
_END_

${installdir}/octave_forge_installer.tcl ${VERSION} miscellaneous 1.0.11
${installdir}/octave_forge_installer.tcl ${VERSION} struct 1.0.9
${installdir}/octave_forge_installer.tcl ${VERSION} optim 1.0.16
${installdir}/octave_forge_installer.tcl ${VERSION} specfun 1.0.9
${installdir}/octave_forge_installer.tcl ${VERSION} signal 1.0.11
