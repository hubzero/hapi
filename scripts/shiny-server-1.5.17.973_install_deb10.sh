#!/bin/bash

# R shiny-server

# show commands being run
set -x

source /etc/environ.sh

# Fail script on error.
set -e

hapidir=$(readlink -f $(dirname $0))
pkgname=shiny-server
VERSION=1.5.17.973
basedir=/apps/share64/debian10
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${pkgname}-${VERSION}
downloaduri=https://github.com/rstudio/shiny-server/archive/v${VERSION}.tar.gz
tarfilebase=shiny-server-${VERSION}
tarfilename=shiny-server-${VERSION}.tgz
environdir=${basedir}/environ.d
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
   mkdir -p ${pkginstalldir}/tars
fi
chmod o-rswx ${pkginstalldir}/tars

cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
   curl -L ${downloaduri} > ${tarfilename}
   chmod o-rsxw ${tarfilename}
fi
rm -rf ${tarfilebase}
tar xzf ${tarfilename}

# Get into a temporary directory in which we'll build the project
cd ${pkginstalldir}/tars/${tarfilebase}

mkdir tmp

cd ${pkginstalldir}/tars/${tarfilebase}/tmp

# Install our private copy of Node.js
../external/node/install-node.sh

# Add the bin directory to the path so we can reference node
PATH=${pkginstalldir}/tars/${tarfilebase}/bin:$PATH

# Use cmake to prepare the make step. Modify the "--DCMAKE_INSTALL_PREFIX"
# if you wish the install the software at a different location.
cmake .. -DCMAKE_INSTALL_PREFIX=${installprefix}

# Recompile the npm modules included in the project
make
mkdir ../build
(cd .. && ./bin/npm install)
(cd .. && ./bin/node ./ext/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js rebuild)

# Install the software at the predefined location
umask 022
make install

# Install default config file
install --mode 644 -D ../config/default.config \
                      ${installprefix}/etc/shiny-server/shiny-server.conf

install --mode 755 -D ${hapidir}/shiny-server-${VERSION}_hubbin_shiny-serverHUB.sh \
                      ${installprefix}/hubbin/shiny-serverHUB.sh

cd ${hapidir}

rm -rf ${pkginstalldir}/tars/${tarfilebase}

if [[ ! -d ${environdir} ]] ; then
   mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}

conflict SHINY_SERVER_CHOICE

desc "shiny server ${VERSION}"

help "Shiny Server is a free and open source development tool for R web applications."

version=${VERSION}

prepend PATH ${installprefix}/shiny-server/bin
prepend PATH ${installprefix}/hubbin

tags DEVEL
_END_
