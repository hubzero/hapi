#! /bin/sh

# show commands being run
set -x

# Fail script on error.
set -e


VERSION=3.4.0

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
