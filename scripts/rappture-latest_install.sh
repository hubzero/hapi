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
pkginstalldir=${basedir}/${pkgname}
installprefix=${pkginstalldir}/${VERSION}
installscript=checkout_repos.sh
downloaduri=http://nanohub.org/infrastructure/rappture-bat/svn/trunk/buildscripts/${installscript}

# download the install script
if [[ ! -e ${installscript} ]] ; then
    curl ${downloaduri} > ${installscript}
fi

# run the install script
bash checkout_repos.sh \
    -p ${installprefix} \
    -d rappture_repositories/trunk


# don't do anything with environment/use scripts yet
#
#if [[ ! -d ${environdir} ]] ; then
#    mkdir -p ${environdir}
#fi
#
#cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
#conflict R_CHOICE
#
#desc "R is a system for statistical computation and graphics. It consists of a language plus a run-time environment with graphics, a debugger, access to certain system functions, and the ability to run programs stored in script files."
#
#help "https://cran.r-project.org"
#
#version=${VERSION}
#location=${pkginstalldir}/\${version}
#
#setenv R_HOME \${location}/lib/R
#
#setenv R_LIBS \$R_HOME/library
#prepend PATH \${location}/bin
#
#prepend MANPATH \${location}/man
#
#tags MATHSCI
#_END_
