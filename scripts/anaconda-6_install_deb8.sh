#! /bin/bash

# Mods for debian8 by JMS
# 2020-05-22
#
# Install anaconda2-6, anaconda3-6, jupyter, jupyter lab and example notebooks.
# Run this, then test it by "use -e anaconda-6; start_jupyter" from
# a workspace or ssh session.  You will need to install the "jupyter"
# tool to allow users to access it.
#
# Now that these repos are private, you must get added as a repo collaborator
# Also be sure to clone to the anaconda directory prior to running install
#	/apps/share64/debian<release>/anaconda/
# and then issue a 'git pull'. These things have been commented below.

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=anaconda
VERSION=6

# Where to install.  Should this be different for different OSes?
basedir=/apps/share64/debian8

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
fi

#cd jupyter_notebook_setup
#git pull
#git checkout ${VERSION}
#cd ..

# if old examples dir exists, create a softlink to it.
#if [[ -e "examples-4.1" ]] ; then
#    ln -sf "examples-4.1" ${example_dir}
#fi

# checkout example notebooks
if [[ ! -e ${example_dir} ]] ; then
    git clone https://github.com/hubzero/jupyter_notebook_examples.git ${example_dir}
fi

#cd ${example_dir}
#git pull
#git checkout 23ccb2494a069eff1a1921a8307d18654079d28d
#cd ..

# now fetch and install binaries

#    parser.add_argument('--with-py2', action='store_true', help='Install Python2')
#    parser.add_argument('--with-nanohub', action='store_true', help='Install tools for materials simulations')
#    parser.add_argument('--with-dash', action='store_true', help='Install Plotly Dash')
#    parser.add_argument('--with-vnc', action='store_true', help='Install VNC')
#    parser.add_argument('--with-ml', action='store_true', help='Install Machine Learning tools')
#    parser.add_argument('--desktop', action='store_true', help='Install Desktop version')
#    parser.add_argument('--envdir', type=str, default='/apps/share64/debian7/environ.d',
#                        help='Environment directory for hubs (default: /apps/share64/debian7/environ.d)')
#    parser.add_argument('--with-r', action='store_true', 
#                        help='Install the R kernel and packages')


./jupyter_notebook_setup/jpkg --with-vnc --with-r --envdir '/apps/share64/debian8/environ.d' --with-dash install ${VERSION}


# setup Rprofile.site
install -D --mode 0444 ${installdir}/Rprofile.site.in ${pkginstalldir2}/lib/R/etc/Rprofile.site
install -D --mode 0444 ${installdir}/Rprofile.site.in ${pkginstalldir3}/lib/R/etc/Rprofile.site

#echo "All done."
#exit 0
