#! /bin/bash

# -p prefix         build name - @TAG, @RPREV, @RTREV are substituted
#                   with the tag number, rappture revision, and runtime
#                   revision numbers.
#                   defaults to "builds/tag_@TAG-@RPREV-@RTREV"
# -d dir            repo directory name - repo_dir, defaults to ./repo
# -o tags/1.3.1     rappture branch - sets rappture_branch,
#                   defaults to latest tag (tags/${TAG})
# -q tags/1.3.1     runtime branch - sets runtime_branch,
#                   defaults to latest tag (tags/${TAG})
# -b branches/1.3   build and test branch - sets bat_branch,
#                   defaults to latest branch (branches/${BRANCH})
# -s script         build script - sets build_script, defaults to hcgrid.sh
# -n                no update - don't update repositories,
#                   use already checked out repos,
#                   only checkout repos if repo dirs don't exist
# -f "flags ..."    additional build script flags
#
# Examples:
#
# 1. build the latest tagged version of rappture.
#    build will be placed in the directory
#    ./repo/builds/tag_@TAG-@RPREV-@RTREV
#    where @TAG, @RPREV, and @RTREV are substituted values.
#
#    ./checkout_repos.sh
#
#
# 2. build the latest tagged version of rappture on a hub
#    using -p flag to set the install prefix
#
#    ./checkout_repos.sh -p /apps/share64/debian7/rappture/tag_@TAG-@RPREV-@RTREV
#
#
# 3. build the latest tagged version of rappture on the grid
#    passing flags to the build script, telling it to build without
#    ffmpeg and without vtk
#
#    ./checkout_repos.sh -f "-r \"--without-ffmpeg --without-vtk\""
#
#
# 4. build the 1.3 branch of rappture by using the -o and -q flags
#    to specify the branch of rappture and runtime
#
#    ./checkout_repos.sh -o branches/1.3 -q branches/1.3 
#
#
# 5. build a specific tag of rappture, also setting a install prefix
#    can't use @TAG with -p flag in this case because @TAG will hold
#    the latest tag instead of the specific tag chosen to be built.
#
#    ./checkout_repos.sh \
#       -p /apps/share64/debian7/rappture/tag_1.3.13-@RPREV-@RTREV \
#       -o tags/1.3.13 \
#       -q tags/1.3.13 \
#       -b branches/1.3
#
# 6. build a specific revision of the rappture and runtime repos
#
#    bash checkout_repos.sh \
#        -p /apps/share64/debian7/rappture/branches_blt4-@RPREV-@RTREV \
#        -d rappture_repositories/branches-blt4 \
#        -o branches/blt4@3286 \
#        -q branches/blt4@1683 \
#        -b trunk \
#        -n
#


build_name="builds/tag_@TAG-@RPREV-@RTREV";
repo_dir=$(readlink -f "./repo");
repo_base="https://nanohub.org/infrastructure"
TAG=`svn ls ${repo_base}/rappture/svn/tags | grep "[0-9]\+\.[0-9]\+\.[0-9]\+" | cut -d'/' -f1  | sort -V | tail -n 1`;
BRANCH=`echo ${TAG} | cut -d'.' -f 1,2`;
rappture_branch=tags/${TAG};
runtime_branch=tags/${TAG};
bat_branch=branches/${BRANCH};
build_script="hcgrid.sh";
build_script_flags="";
update_svn=true;
options=":d:o:q:p:b:s:f:n";

# parse the command line flags and options
# separate flags from options

let nNamedArgs=0
let nUnnamedArgs=0
while (( "$#" ))
do
   case $1 in
      -n )
           namedArgs[$nNamedArgs]=$1
           let nNamedArgs++
           shift
           ;;
      -* )
           namedArgs[$nNamedArgs]=$1
           let nNamedArgs++
           shift
           namedArgs[$nNamedArgs]=$1
           let nNamedArgs++
           shift
           ;;
       * )
           unnamedArgs[$nUnnamedArgs]=$1
           let nUnnamedArgs++
           shift
           ;;
   esac
done

while getopts "${options}" Option "${namedArgs[@]}"
do
   case $Option in
      p ) build_name=$OPTARG;;
      d ) repo_dir=$(readlink -f "$OPTARG");;
      o ) rappture_branch=$OPTARG;;
      q ) runtime_branch=$OPTARG;;
      b ) bat_branch=$OPTARG;;
      s ) build_script=$OPTARG;;
      f ) build_script_flags=$OPTARG;;
      n ) update_svn=false
   esac
done


rappture_url=${repo_base}/rappture/svn/${rappture_branch}
runtime_url=${repo_base}/rappture-runtime/svn/${runtime_branch}
bat_url=${repo_base}/rappture-bat/svn/${bat_branch}

rappture_co_dir=rappture_$(echo ${rappture_branch} | sed -e "s/\//_/g")
runtime_co_dir=runtime_$(echo ${runtime_branch} | sed -e "s/\//_/g")


# checkout or update the rappture, runtime, and bat repositories
mkdir -p ${repo_dir};

cd ${repo_dir};

rm -rf stage1 stage2 stage3 stage.rappture

# checkout the rappture repo if the directory does not exist
if [[ ! -d ${rappture_co_dir} ]] ; then
    svn -q checkout ${rappture_url} ${rappture_co_dir};
    exitStatus=$?
    if [ ${exitStatus} -eq 0 ] ; then
        coComplete=1
    else
        coComplete=0
    fi
    if [ ${coComplete} -eq 0 ] ; then
        cd ${rappture_co_dir}
        while [ ${coComplete} -eq 0 ] ; do
            svn cleanup
            svn -q update
            exitStatus=$?
            if [ ${exitStatus} -eq 0 ] ; then
                coComplete=1
            fi
        done
    fi
fi

cd ${repo_dir}

# checkout the runtime repo if the directory does not exist
if [[ ! -d ${runtime_co_dir} ]] ; then
    svn -q checkout ${runtime_url} ${runtime_co_dir};
    exitStatus=$?
    if [ ${exitStatus} -eq 0 ] ; then
        coComplete=1
    else
        coComplete=0
    fi
    if [ ${coComplete} -eq 0 ] ; then
        cd ${runtime_co_dir}
        while [ ${coComplete} -eq 0 ] ; do
            svn cleanup
            svn -q update
            exitStatus=$?
            if [ ${exitStatus} -eq 0 ] ; then
                coComplete=1
            fi
        done
    fi
fi

cd ${repo_dir}

if [ "${update_svn}" = true ] ; then

    # update the rappture and runtime repos.
    # if we can't update, then checkout a fresh copy

    cd ${rappture_co_dir};
    { # try to svn update
        svn cleanup &&
        svn revert -R . &&
        svn update &&
        cd ../
    } || {  # if the update fails, do an svn checkout
        cd ../ &&
        rm -rf ${rappture_co_dir} &&
        svn -q checkout ${rappture_url} ${rappture_co_dir}
    }

    cd ${runtime_co_dir};
    { # try to svn update
        svn cleanup &&
        svn revert -R . &&
        svn update &&
        cd ../
    } || {  # if the update fails, do an svn checkout
        cd ../ &&
        rm -rf ${runtime_co_dir} &&
        svn -q checkout ${runtime_url} ${runtime_co_dir}
    }
fi

# create links for rappture and runtime
rm -f rappture;
ln -s ${rappture_co_dir} rappture;
rm -f runtime;
ln -s ${runtime_co_dir} runtime;

if [ ! -f ${build_script} ] ; then
   # export the build script
   svn export ${bat_url}/buildscripts/${build_script}
fi

# get the rappture revision
cd rappture;
rappture_svn_revision=`svn info | grep "Last Changed Rev" | cut -d" " -f 4`;
cd -;

# get the runtime revision
cd runtime;
runtime_svn_revision=`svn info | grep "Last Changed Rev" | cut -d" " -f 4`;
cd -;

build_name=$(echo ${build_name} | sed -e "s/@TAG/${TAG}/g" \
    -e "s/@RPREV/${rappture_svn_revision}/g" \
    -e "s/@RTREV/${runtime_svn_revision}/g");

# run the build script
eval ./"${build_script}" -p "${build_name}" "${build_script_flags}";


