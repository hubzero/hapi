#!/bin/bash

# rstudio-server relies on the PAM headers and libraries from the debian package libpam0g-dev

# show commands being run
set -x

source /etc/environ.sh
use -e -r R-4.0.5

# Fail script on error.
set -e


hapidir=$(readlink -f $(dirname $0))
pkgname=rstudio-server
VERSION=1.4.1717
basedir=/apps/share64/debian10
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=https://github.com/rstudio/rstudio/archive/v${VERSION}.tar.gz
tarfilebase=rstudio-${VERSION}
tarfilename=rstudio-${VERSION}.tgz
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})
# patchpath=$(dirname ${installdir})/extra/rstudio/rstudio_boost_pointer.patch

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    curl -L ${downloaduri} > ${tarfilename}
fi
rm -rf ${tarfilebase}
tar xzf ${tarfilename}

#sed -e "s:^./install-boost:#./install-boost:" -i ${tarfilebase}/dependencies/common/install-common
sed -e "s:^./install-sentry-cli:#./install-sentry-cli:" -i ${tarfilebase}/dependencies/common/install-common

# By default installation is to /opt/rstudio-tools which requires root permission
export RSTUDIO_TOOLS_ROOT=${installprefix}/rstudio-tools
# Disable crashpad build.  It fails because the old version of llvm used does not compile with gcc 8.3
export RSTUDIO_DISABLE_CRASHPAD=1

#install dependencies
cd ${pkginstalldir}/tars/${tarfilebase}/dependencies/common
./install-common

#cd ${pkginstalldir}/tars/${tarfilebase}/dependencies/linux
#./install-qt-sdk

cd ${pkginstalldir}/tars/${tarfilebase}

## lowering the number of workers as per
## https://support.rstudio.com/hc/en-us/community/posts/201034828-Unable-to-compile-RStudio-Server-on-a-Raspberry-Pi
#cat <<- _END_ > rstudio_java_memory.patch
#diff -rupN src/gwt/build.xml src.new/gwt/build.xml
#--- src/gwt/build.xml	2016-10-18 17:32:41.000000000 -0400
#+++ src.new/gwt/build.xml	2016-11-14 01:13:20.579551344 -0500
#@@ -102,11 +102,12 @@
#             <path refid="project.class.path"/>
#          </classpath>
#          <!-- add jvmarg -Xss16M or similar if you see a StackOverflowError -->
#+         <jvmarg value="-Xss16M"/>
#          <jvmarg value="-Xmx1536M"/>
#          <arg value="-war"/>
#          <arg value="www"/>
#          <arg value="-localWorkers"/>
#-         <arg value="2"/>
#+         <arg value="1"/>
#          <arg value="-XdisableClassMetadata"/>
#          <arg value="-XdisableCastChecking"/>
#          <arg line="-strict"/>
#_END_
#
#patch -p0 < rstudio_java_memory.patch


## R_CMethodDef struct seems to no longer have a styles member.
#cat <<- _END_ > rstudio_RCMethodDef_styles.patch
#--- src/cpp/r/RRoutines.cpp 2017-05-26 11:20:24.451598046 -0400
#+++ src/cpp/r/RRoutines.cpp.new 2017-05-26 11:20:11.877663778 -0400
#@@ -59,7 +59,7 @@ void registerAll()
#       nullMethodDef.fun = NULL ;
#       nullMethodDef.numArgs = 0 ;
#       nullMethodDef.types = NULL;
#-      nullMethodDef.styles = NULL;
#+      //nullMethodDef.styles = NULL;
#       s_cMethods.push_back(nullMethodDef);
#       pCMethods = &s_cMethods[0];
#    }
#_END_
#
#patch -p0 < rstudio_RCMethodDef_styles.patch


rm -rf build
mkdir -p build
cd build

export GIT_DISCOVERY_ACROSS_FILESYSTEM=1
#export _JAVA_OPTIONS="-Xms512M"

cmake .. -DCMAKE_INSTALL_PREFIX=${installprefix} \
         -DRSTUDIO_TARGET=Server \
         -DCMAKE_BUILD_TYPE=Release

umask 022
make install

install --mode 755 -D ${hapidir}/rstudio-server-1.4.1717_hubbin_rserverHUB.sh \
                      ${installprefix}/hubbin/rserverHUB.sh
install --mode 755 -D ${hapidir}/rstudio-server-1.4.1717_hubbin_rstudioUserAuthentication.sh \
                      ${installprefix}/hubbin/rstudioUserAuthentication.sh

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict RSTUDIO_SERVER_CHOICE

desc "RStudio Server ${VERSION}"

help "RStudio Server is a free and open source integrated development environment for R for the web."

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin/pandoc
prepend PATH \${location}/bin

tags DEVEL
_END_
