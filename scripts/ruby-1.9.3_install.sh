#! /bin/bash

# NOTES:
# R's gui, Rcmdr, requires some of these debian packages too:
#   tcl, tcl-dev, tk, tk-dev

# show commands being run
set -x

# Fail script on error.
set -e

pkgname=ruby
VERSION=1.9.3
basedir=/apps/share64/debian7
pkginstalldir=${basedir}/${pkgname}
tarinstalldir=${pkginstalldir}/tars
installprefix=${pkginstalldir}/${VERSION}
downloaduri=ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p448.tar.gz
tarfilebase=ruby-${VERSION}-p448
tarfilename=${tarfilebase}.tar.gz
environdir=${basedir}/environ.d
rinstallpath=${basedir}/R/2.15.3/lib/R
script=$(readlink -f ${0})
installdir=$(dirname ${script})

if [[ ! -d ${pkginstalldir}/tars ]] ; then
    mkdir -p ${pkginstalldir}/tars
fi
cd ${pkginstalldir}/tars

if [[ ! -e ${tarfilename} ]] ; then
    wget ${downloaduri}
fi
rm -rf ${tarfilebase}
tar xvzf ${tarfilename}
cd ${tarfilebase}
./configure  --prefix=${installprefix}
make all
make install

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/${pkgname}-${VERSION}
conflict RUBY_CHOICE

desc "Ruby ${VERSION}"

help "A dynamic, open source programming language with a focus on simplicity
and productivity. It has an elegant syntax that is natural to read and easy to
write.  "

version=${VERSION}
location=${pkginstalldir}/\${version}

prepend PATH \${location}/bin

prepend MANPATH \${location}/man
prepend GEM_HOME \${location}/gems
prepend RUBYPATH \${location}/bin
prepend RUBYLIB \${location}/lib


tags DEVEL
_END_

. /etc/environ.sh
use -e -r ${pkgname}-${VERSION}
export GEM_HOME=${installprefix}/gems
gem install dicom
gem install rtkit
gem install nifti
gem install rails
gem install gchart
gem install rsruby -- --with-R-dir=${rinstallpath} --with-R-include=${rinstallpath}/include
gem install sqlite3
gem install authlogic
gem install paperclip
gem install narray

