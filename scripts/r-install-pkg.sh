#! /bin/bash

# USAGE:
#
# OPTIONS:
#
#   R   set the version of R to use
#       defaults to version 3.2.1
#
#   a   set the action of the script. valid actions include:
#       "install_cran", "install_github", "install_bioc",
#       "install_svn", "install", "remove", "update", 
#       or other devtools::install* commands
#       defaults to "instal_cran"
#
# EXAMPLES:
#
#   1. install a package:
#   
#       ./r-install-pkg.sh shiny
#
#   2. install a package from CRAN, specifying the action and R version
#
#       ./r-install-pkg.sh -a install_cran -R 3.2.1 shiny
#
#   3. install multiple packages from CRAN
#
#       ./r-install-pkg.sh shiny tibble tidyr
#
#   4. install a package from github, specifying the action and R version
#
#       ./r-install-pkg.sh -a install_github -R 3.2.1 jcheng5/d3scatter
#
#   5. remove a package named shiny
#   
#       ./r-install-pkg.sh -a remove shiny
#
#   6. remove multiple packages
#
#       ./r-install-pkg.sh -a remove shiny tibble tidyr
#
#   7. update packages
#
#       ./r-install-pkg.sh -a update




die () {
    echo >&2 "$@"
    echo 1
    exit 1
}

function bootstrap() {
    # install R packages
    R -e "install.packages('devtools', repos=c(${cran_repos}))";
    R -e 'source("http://bioconductor.org/biocLite.R"); biocLite("BiocInstaller")'
}

function install() {
    # install R packages
    for cranpkg in ${cran_packages}
    do
        echo "installing package: ${cranpkg}";
        if [[ "${action}" == "install_cran" ]] ; then
            R -e "devtools::${action}('${cranpkg}', repos=c(${cran_repos}))";
        else
            R -e "devtools::${action}('${cranpkg}')";
        fi
    done
}

function remove() {
    for cranpkg in ${cran_packages}
    do
        echo "removing package: ${cranpkg}";
        R -e "remove.packages('${cranpkg}')";
    done
}

function update() {
    echo "updating package(s)";
    R -e "update.packages(repos=c(${cran_repos}),ask=FALSE)";
}



action="install_cran"
cran_packages=""
version="3.2.1"

# cran_repos list is a single-quoted, comma separated list
cran_repos="\
    'http://cran.rstudio.com/', \
    'http://cran.wustl.edu/', \
    'http://cran.revolutionanalytics.com/' \
"

options=":a:R:"

let nNamedArgs=0
let nUnnamedArgs=0
namedArgs=""
unnamedArgs=""

while (( "$#" ))
do
   case $1 in
#      -v )
#           namedArgs[${nNamedArgs}]=$1
#           let nNamedArgs++
#           shift
#           ;;
      -* )
           namedArgs[${nNamedArgs}]=$1
           let nNamedArgs++
           shift
           namedArgs[${nNamedArgs}]=$1
           let nNamedArgs++
           shift
           ;;
       * )
           unnamedArgs[${nUnnamedArgs}]=$1
           let nUnnamedArgs++
           shift
           ;;
   esac
done

while getopts "${options}" Option "${namedArgs[@]}"
do
   case ${Option} in
      a ) action=${OPTARG};;
      R ) version=${OPTARG};;
   esac
done

# Fail script on error.
set -e

# no uninitialized variables
set -u

for pkg in ${unnamedArgs[@]}
do
    echo ${pkg}| grep -E -q '^[a-zA-Z0-9.+-_]+$' || die "Bad package name: ${pkg}";
    cran_packages="${cran_packages} ${pkg}";
done

# check for a valid action: "install*", "remove", or "update"
#install_re='^install.*$'
#if [[ ! "$action" =~ $install_re && "$action" != "remove" && "$action" != "update" ]] 
#then
#    die "Bad action \"$action\": should be one of (install,remove,update)"
#fi

# setup the version of R to install packages into
set +e
source /etc/environ.sh
set -e
use -e -r R-${version}

case $action in
    install* ) 
        install;;
    remove|update|check|bootstrap )
        $action;;
    * )
        die "Bad action \"$action\": should be one of (install,remove,update)"
esac
