#! /bin/bash

# this needs the following debian packages:
#   libnetcdf-dev
#   libv8-3.14-dev
#   libproj-dev (needed by rgdal package)
#   libudunits2-dev (needed by sf package)
#
# additional optional packages:
#   tcl-dev
#   tk-dev

# show commands being run
set -x

rversion=4.0.5

# setup the R environment
source /etc/environ.sh
use -e -r R-${rversion}

# Fail script on error.
set -e

script=$(readlink -f ${0})
installdir=$(dirname ${script})

# install packages
${installdir}/r-pkg-sync --packagelist ${installdir}/r-${rversion}-package_list.csv
