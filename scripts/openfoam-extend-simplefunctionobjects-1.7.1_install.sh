#!/bin/bash

# show commands being run
set -x

# Fail script on error.
set -e


#WM_PROJECT_DIR=/apps/Packages/OpenFOAM/OpenFOAM-1.7.1
#WMAKE=${WM_PROJECT_DIR}/wmake/wmake

origdir=$(pwd)

SFODIR=/apps/Packages/OpenFOAM-Extend/simpleFunctionObjects

if [[ ! -d ${SFODIR} ]] 
then
    mkdir -p ${SFODIR}
fi

cd ${SFODIR}

if [[ ! -d 1.6 ]]
then
    svn checkout \
        https://openfoam-extend.svn.sourceforge.net/svnroot/openfoam-extend/trunk/Breeder_1.6/libraries/simpleFunctionObjects 1.6
fi

cd 1.6

# setup basic openfoam environment variables
. /apps/Packages/OpenFOAM/OpenFOAM-1.7.1/etc/bashrc

# setup wmake path
. ${WM_PROJECT_DIR}/etc/settings.sh

# simpleFunctionObjects are installed in $FOAM_USER_LIBBIN
# we want them in $FOAM_SITE_LIBBIN  instead
FOAM_USER_LIBBIN=${FOAM_SITE_LIBBIN}

echo "wmake = $(which wmake)"

# compile
wmake libso

cd $origidr
