#! /bin/sh

VERSION=3.0
script=$(readlink -f ${0})
installdir=$(dirname ${script})
share_version=share64
environdir=/apps/${share_version}/environ
irods_installdir=/apps/${share_version}/irods

if [[ ! -d ${irods_installdir} ]] ; then
    mkdir -p ${irods_installdir}
fi
cd ${irods_installdir}

if [[ ! -d tars ]] ; then
    mkdir tars
fi
cd tars
irods_tar=irods${VERSION}.tgz
if [[ ! -e ${irods_tar} ]] ; then
    wget --no-check-certificate http://irods.sdsc.edu/cgi-bin/upload15.cgi/${irods_tar}
fi
tar xvzf ${irods_tar}
cd iRODS

# FIXME:
# need to run irodssetup from here

if [[ ! -d ${environdir} ]] ; then
    mkdir ${environdir}
fi

cat <<- _END_ > ${environdir}/irods-${VERSION}
conflict IRODS_CHOICE

desc "iRODS Integrated Rule-Oriented Data System"

help "iRODS ${VERSION}"

version=${VERSION}
location=${irods_installdir}/\${version}

prepend PATH    \${location}/icommands/bin
prepend PATH    \${location}/fuse/bin
setenv IRODS_MOUNT \${location}/mount_fuse.sh

_END_
