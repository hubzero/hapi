#! /bin/bash

# Update anaconda2-4.1, anaconda3-4.1, jupyter and example notebooks

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=anaconda
VERSION=4.1

# where to update
basedir=/apps/share64/debian7

pkginstalldir=${basedir}/${pkgname}/${VERSION}
example_dir=examples-${VERSION}
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

# Create installation directory if necessary
if [[ ! -d ${pkginstalldir} ]] ; then
    mkdir -p ${pkginstalldir}
fi
cd ${pkginstalldir}

# checkout notebook_setup
if [[ ! -e "jupyter_notebook_setup" ]] ; then
    git clone https://github.com/hubzero/jupyter_notebook_setup.git
else
    cd jupyter_notebook_setup
    git pull
    cd ..
fi

# checkout example notebooks
if [[ ! -e ${example_dir} ]] ; then
    git clone https://github.com/hubzero/jupyter_notebook_examples.git ${example_dir}
else
    cd ${example_dir}
    git pull
    cd ..
fi

# now install and configure anaconda2, anaconda3 and jupyter
./jupyter_notebook_setup/jpkg update nano_4.1

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}2-${VERSION}
conflict ANACONDA_CHOICE

desc "Python distribution for large-scale data processing, predictive analytics, and scientific computing."

help "https://docs.continuum.io/new-anaconda-start-here"

version=${VERSION}
location=${pkginstalldir}

prepend PATH \${location}/anaconda2-\${version}/bin

tags MATHSCI
_END_


cat <<- _END_ > ${environdir}/${pkgname}3-${VERSION}
conflict ANACONDA_CHOICE

desc "Python distribution for large-scale data processing, predictive analytics, and scientific computing."

help "https://docs.continuum.io/new-anaconda-start-here"

version=${VERSION}
location=${pkginstalldir}

prepend PATH \${location}/anaconda3-\${version}/bin

tags MATHSCI
_END_

