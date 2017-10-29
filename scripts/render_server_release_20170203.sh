#!/bin/sh

# Fail script on error.
set -e

host_os=`uname -s`
echo "host OS: $host_os"

base_dir=/opt/hubzero/rappture
build_dir=$base_dir/`date +%Y%m%d`
mkdir -p $build_dir

stage1_flags=" \
"
# If building without DX support in nanovis add:
# --without-voronoi
stage2_flags=" \
 --with-osg \
"
stage3_flags=" \
 --with-osgearth \
"

# Only need the core libs for nanovis
rappture_flags="--disable-gui --disable-lang --disable-vtkdicom --without-ffmpeg"

nanoscale_flags="--with-logdir=/tmp --with-statsdir=/var/log/visservers"
geovis_flags="--with-logdir=/tmp --with-statsdir=/var/log/visservers"
nanovis_flags="--with-logdir=/tmp --with-statsdir=/var/log/visservers --with-rappture=$build_dir --with-vtk=6.2"
pymolproxy_flags="--with-logdir=/tmp --with-statsdir=/var/log/visservers"
vtkvis_flags="--with-logdir=/tmp --with-statsdir=/var/log/visservers"
vmdshow_flags="--with-logdir=/tmp --with-statsdir=/var/log/visservers"

MAKE=make
MAKEFLAGS=-j10
case $host_os in
   *Darwin* )
      DYLD_LIBRARY_PATH=$build_dir/lib
      export DYLD_LIBRARY_PATH
      ;;
   *Linux*  )
      LD_LIBRARY_PATH=$build_dir/lib
      export LD_LIBRARY_PATH
      ;;
   *FreeBSD* )
      MAKE=gmake
      LD_LIBRARY_PATH=$build_dir/lib
      export LD_LIBRARY_PATH
      ;;
esac

PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin:/usr/bin/X11:/usr/X11/bin:/usr/openwin/bin:$build_dir/bin

export MAKE MAKEFLAGS PATH

# Rappture is only required to build nanovis, and nanovis only requires a small
# portion of the Rappture C++ core library.  The GUI components and language
# bindings of Rappture are not required.  Since the rappture core has remained 
# stable for some time, the choice of tag/branch for Rappture is not so critical
# here.

RUNTIME_PATH=branches/render-release
RAPPTURE_PATH=trunk
NANOSCALE_PATH=tags/1.0.3
GEOVIS_PATH=tags/1.0.0
NANOVIS_PATH=tags/1.2.6
PYMOLPROXY_PATH=tags/1.0.3
VTKVIS_PATH=tags/1.8.9
VMDSHOW_PATH=tags/0.2.1

if test -d "runtime" ; then
    echo "found runtime"
else
    svn co https://nanohub.org/infrastructure/rappture-runtime/svn/${RUNTIME_PATH} runtime || exit 1
    pwd=`pwd`
    cd runtime && ./bootstrap && cd $pwd
    #echo "runtime directory does not exist, run this to check out a copy:"
    #echo "svn co https://nanohub.org/infrastructure/rappture-runtime/svn/${RUNTIME_PATH} runtime"
    #exit 1
fi
if test -d "rappture" ; then
    echo "found rappture"
else
    svn co https://nanohub.org/infrastructure/rappture/svn/${RAPPTURE_PATH} rappture || exit 1
    #echo "rappture directory does not exist, run this to check out a copy:"
    #echo "svn co https://nanohub.org/infrastructure/rappture/svn/${RAPPTURE_PATH} rappture"
    #exit 1
fi
if test -d "geovis" ; then
    echo "found geovis"
else
    svn co https://nanohub.org/infrastructure/rappture/svn/geovis/${GEOVIS_PATH} geovis || exit 1
fi
if test -d "nanoscale" ; then
    echo "found nanoscale"
else
    svn co https://nanohub.org/infrastructure/rappture/svn/nanoscale/${NANOSCALE_PATH} nanoscale || exit 1
fi
if test -d "nanovis" ; then
    echo "found nanovis"
else
    svn co https://nanohub.org/infrastructure/rappture/svn/nanovis/${NANOVIS_PATH} nanovis || exit 1
fi
if test -d "pymolproxy" ; then
    echo "found pymolproxy"
else
    svn co https://nanohub.org/infrastructure/rappture/svn/pymolproxy/${PYMOLPROXY_PATH} pymolproxy || exit 1
fi
if test -d "vtkvis" ; then
    echo "found vtkvis"
else
    svn co https://nanohub.org/infrastructure/rappture/svn/vtkvis/${VTKVIS_PATH} vtkvis || exit 1
fi
#if test -d "vmdbuild" ; then
#    echo "found vmdbuild"
#else
#   svn co https://nanohub.org/infrastructure/rappture-bat/svn/trunk/vmdbuild vmdbuild
#fi
if test -d "vmdshow" ; then
    echo "found vmdshow"
else
   svn co https://nanohub.org/infrastructure/rappture/svn/vmdshow/${VMDSHOW_PATH} vmdshow || exit 1
fi

stage1() {
    pwd=`pwd`
    if test -d "stage1" ; then
      cd stage1
    else
      mkdir -p stage1
      cd stage1
      ../runtime/configure --prefix=$build_dir --exec_prefix=$build_dir \
       $stage1_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

stage2() {
    pwd=`pwd`
    if test -d "stage2" ; then
      cd stage2
    else
      mkdir -p stage2
      cd stage2
      ../runtime/configure --prefix=$build_dir --exec_prefix=$build_dir \
       $stage2_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

stage3() {
    pwd=`pwd`
    if test -d "stage3" ; then
      cd "stage3"
    else
      mkdir -p stage3
      cd stage3
     ../runtime/configure --prefix=$build_dir --exec_prefix=$build_dir \
       $stage3_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

nanoscale() {
    pwd=`pwd`
    if test -d "stage.nanoscale" ; then
      cd "stage.nanoscale"
    else
      mkdir -p stage.nanoscale
      cd stage.nanoscale
      ../nanoscale/configure --prefix=$build_dir $nanoscale_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

pymolproxy() {
    pwd=`pwd`
    if test -d "stage.pymolproxy" ; then
      cd "stage.pymolproxy"
    else
      mkdir -p stage.pymolproxy
      cd stage.pymolproxy
      ../pymolproxy/configure --prefix=$build_dir $pymolproxy_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

geovis() {
    pwd=`pwd`
    if test -d "stage.geovis" ; then
      cd "stage.geovis"
    else
      mkdir -p stage.geovis
      cd stage.geovis
      ../geovis/configure --prefix=$build_dir $geovis_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

rappture() {
    pwd=`pwd`
    if test -d "stage.rappture" ; then
      cd "stage.rappture"
    else
      mkdir -p stage.rappture
      cd stage.rappture
      ../rappture/configure --prefix=$build_dir $rappture_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

nanovis() {
    pwd=`pwd`
    if test -d "stage.nanovis" ; then
      cd "stage.nanovis"
    else
      mkdir -p stage.nanovis
      cd stage.nanovis
      ../nanovis/configure --prefix=$build_dir $nanovis_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

vtkvis() {
    pwd=`pwd`
    if test -d "stage.vtkvis" ; then
      cd "stage.vtkvis"
    else
      mkdir -p stage.vtkvis
      cd stage.vtkvis
      ../vtkvis/configure --prefix=$build_dir $vtkvis_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

vmd() {
    pwd=`pwd`
    if test -d "stage.vmd" ; then
      cd "stage.vmd"
    else
      mkdir -p stage.vmd
      cd stage.vmd
      ../vmdbuild/configure --prefix=$build_dir $vmd_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

vmdshow() {
    pwd=`pwd`
    if test -d "stage.vmdshow" ; then
      cd "stage.vmdshow"
    else
      mkdir -p stage.vmdshow
      cd stage.vmdshow
      ../vmdshow/configure --prefix=$build_dir $vmdshow_flags
    fi
    ${MAKE} all 2>&1 | tee make.log
    ${MAKE} install 2>&1 | tee install.log
    cd $pwd
}

stage1
stage2
stage3
nanoscale
pymolproxy
geovis
vtkvis
vmdshow
rappture
nanovis

exit 0
