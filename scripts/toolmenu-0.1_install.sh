#!/bin/bash

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=toolmenu
VERSION=0.1
basedir=/apps/share64/debian7
environdir=${basedir}/environ.d
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
tarfilename=${pkgname}_v${VERSION}.tar.gz
tarfilebase=${pkgname}-${pkgname}_v${VERSION}
downloaduri=https://github.com/codedsk/${pkgname}/archive/${tarfilename}
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi

rm -rf ${installprefix}
mkdir -p ${installprefix}

tar xvzf ${tarfilename}

install --mode 0755 -D ${tarfilebase}/bin/toolmenu ${installprefix}/bin/toolmenu
for f in `ls ${tarfilebase}/examples/*.jpg`; do
    install --mode 0444 -D ${f} ${installprefix}/${f#${tarfilebase}/}
done
install --mode 0444 -D ${tarfilebase}/examples/toolmenu.conf ${installprefix}/examples/toolmenu.conf


cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict TOOLMENU_CHOICE

desc "Configurable menu for launching graphical user interfaces."

help "https://github.com/codedsk/toolmenu"

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin

tags DEVEL
_END_
