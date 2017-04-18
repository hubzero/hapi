#!/bin/bash

# anaconda script download script lives here:
# http://continuum.io/downloads

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=anaconda
VERSION=2.3.0
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
anaconda_install_script=Anaconda-${VERSION}-Linux-x86_64.sh
downloaduri=https://repo.continuum.io/archive/${anaconda_install_script}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${anaconda_install_script} ]] ; then
    wget ${downloaduri}
fi

rm -rf ${installprefix}

bash ${anaconda_install_script} -p ${installprefix} -b -f

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict ANACONDA_CHOICE

desc "Python distribution for large-scale data processing, predictive analytics, and scientific computing."

help "https://store.continuum.io/cshop/anaconda"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin

# To pick up submit
setenv  PYTHONPATH /usr/local/lib/python2.7/dist-packages

tags MATHSCI
_END_


# we want the very latest versions of these
${installprefix}/bin/conda update --yes conda
${installprefix}/bin/conda update --yes anaconda
${installprefix}/bin/conda update --yes ipython ipython-notebook ipython-qtconsole

# also install these
${installprefix}/bin/conda install --yes pymc
${installprefix}/bin/conda install --yes mathjax
${installprefix}/bin/conda install --yes seaborn
${installprefix}/bin/conda install --yes jupyter

# also install R kernel and common R packages
${installprefix}/bin/conda install --yes -c http://conda.anaconda.org/r r-essentials

# install with pip
${installprefix}/bin/pip install GPy
${installprefix}/bin/pip install common
${installprefix}/bin/pip install pydstool
${installprefix}/bin/pip install pyttk
${installprefix}/bin/pip install shapely
