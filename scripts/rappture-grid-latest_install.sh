#! /bin/bash

function load_latest_use_env_for() {
    use_script_name=`use -h 2>&1 | \
                        grep "$1" | \
                        cut -d':' -f1 | \
                        sort -V | \
                        tail -n 1`;
    if [[ "x${use_script_name}" != "x" ]] ; then
        use -e -r ${use_script_name};
    fi
}

# show commands being run
set -x

# setup use environments
source /etc/environ.sh

# load the R programming environment
load_latest_use_env_for "R-[0-9]\+\.[0-9]\+\.[0-9]\+"

# load MATLAB programming environment
load_latest_use_env_for "matlab-[0-9]\+\.[0-9]\+"


# Fail script on error.
set -e

# no uninitialized variables
set -u

pkgname=rappture
VERSION=tag_@TAG-@RPREV-@RTREV
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}/grid
installprefix=${pkginstalldir}/${VERSION}
installscript=checkout_repos.sh
downloaduri=http://nanohub.org/infrastructure/rappture-bat/svn/trunk/buildscripts/${installscript}

# download the install script
if [[ ! -e ${installscript} ]] ; then
    curl ${downloaduri} > ${installscript}
fi

# run the install script
# we need tk to build blt. if we use bltlite, we might be able to get rid of tk
# we might not need expect
bash checkout_repos.sh \
    -p ${installprefix} \
    -d rappture_repositories/gridexec \
    -f "-1 \"--without-cmake --with-expat --with-zlib\" -2 \"--without-htmlwidget --without-itk --without-shape --without-tkimg --without-vornoi\" -3 \"--without-vtk --without-pymol --without-dx\" -r \"--without-ffmpeg --without-vtk\""

