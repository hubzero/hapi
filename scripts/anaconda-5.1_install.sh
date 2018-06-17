#! /bin/bash

# Install anaconda2-5.1, anaconda3-5.1, jupyter, jupyter lab and example notebooks.
# Run this, then test it by "use -e anaconda3-5.1; start_jupyter" from
# a workspace or ssh session.  You will need to install the "jupyter"
# tool to allow users to access it.

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=anaconda
VERSION=5.1

# Where to install.  Should this be different for different OSes?
basedir=/apps/share64/debian7

pkginstalldir=${basedir}/${pkgname}
# install dir for anaconda2
pkginstalldir2=${basedir}/${pkgname}/${pkgname}2-${VERSION}
# install dir for anaconda3
pkginstalldir3=${basedir}/${pkgname}/${pkgname}3-${VERSION}
example_dir=examples
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

# Create installation directory if necessary
if [[ ! -d ${pkginstalldir} ]] ; then
    mkdir -p ${pkginstalldir}
fi
cd ${pkginstalldir}

# Checkout notebook_setup script
if [[ ! -e "jupyter_notebook_setup" ]] ; then
    git clone https://github.com/hubzero/jupyter_notebook_setup.git
else
    cd jupyter_notebook_setup
    git pull
    cd ..
fi

# if old examples dir exists, create a softlink to it.
if [[ -e "examples-4.1" ]] ; then
    ln -s "examples-4.1" ${example_dir}
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
# For now we are using the nanohub configuration.  Hub-specific
# configurations are possible.

./jupyter_notebook_setup/jpkg install hublight_${VERSION}

# setup Rprofile.site
install -D --mode 0444 ${installdir}/Rprofile.site.in ${pkginstalldir2}/lib/R/etc/Rprofile.site
install -D --mode 0444 ${installdir}/Rprofile.site.in ${pkginstalldir3}/lib/R/etc/Rprofile.site

if [[ ! -d ${environdir} ]] ; then
    mkdir -p ${environdir}
fi

# anaconda2 env file
cat <<- _END_ > ${environdir}/${pkgname}2-${VERSION}
conflict ANACONDA_CHOICE

desc "Anaconda® is a package manager, an environment manager, a Python distribution, and a collection of over 1,000+ open source packages.""

help "https://docs.anaconda.com/new-anaconda-start-here"

version=${VERSION}
location=${pkginstalldir2}

prepend PATH \${location}/bin

tags MATHSCI
_END_


# anaconda3 env file
cat <<- _END_ > ${environdir}/${pkgname}3-${VERSION}
conflict ANACONDA_CHOICE

desc "Anaconda® is a package manager, an environment manager, a Python distribution, and a collection of over 1,000+ open source packages.""

help "https://docs.anaconda.com/new-anaconda-start-here"

version=${VERSION}
location=${pkginstalldir3}

prepend PATH \${location}/bin

tags MATHSCI
_END_

