#! /bin/bash
#
# install R packages
# assumes the following debian packages were installed:
# libcairo2-dev, libxt-dev for Cairo package
# libpam0g-dev for rstudio server stuff
# libnetcdf-dev for netcdf, xcms
# jags for rjags
# libv8-3.14-dev for rmapshaper
# libprotobuf-dev for geojson


# show commands being run
set -x

# Fail script on error.
#set -e

pkgname=R
VERSION=3.2.5
script=$(readlink -f ${0})
installdir=$(dirname ${script})



cran_packages="\
    MCMCpack \
    mvtnorm \
    EbayesThresh \
    survival \
    Hmisc \
    VGAM \
    cluster \
    glmnet \
    igraph \
    mixOmics \
    pamr \
    pls \
    pvclust \
    rgl \
    spls \
    pwr \
    dcemriS4 \
    oro.nifti \
    oro.dicom \
    agRee \
    Agreement \
    ggplot2 \
    googleVis \
    R.matlab \
    XML \
    RCurl \
    deSolve \
    rootSolve \
    minpack.lm \
    MASS \
    coda \
    lattice \
    FME \
    mnormt \
    waterData \
    EcoHydRology \
    hydroTSM \
    foreign \
    reshape \
    gdata \
    spdep \
    spgrass6 \
    ncdf4 \
    plyr \
    maptools \
    gridExtra \
    corrplot \
    systemfit \
    plm \
    countrycode \
    stargazer \
    msm \
    rgeos \
    classInt \
    shiny \
    shinydashboard \
    colorspace \
    Cairo \
    maxlike \
    rgdal \
    gdalUtils \
    AUC \
    pander \
    dplyr \
    rmarkdown \
    optparse \
    maps \
    ggmap \
    hexbin \
    RColorBrewer \
    ordinal \
    pheatmap \
    proto \
    ucminf \
    sqldf \
    DT \
    matrixcalc \
    optimx \
    plotly \
    tidyr \
    viridis \
    tibble \
    d3heatmap \
    flexdashboard \
    devtools \
    crosstalk \
    servr \
    raster \
    rmapshaper \
    tigris \
    acs \
    sf \
    mapview \
    geojson \
    geojsonio \
    tidyverse \
    gapminder \
    rbokeh \
    visNetwork \
    reticulate \
"

github_packages="\
    jcheng5/d3scatter \
    rstudio/leaflet \
    hafen/trelliscopejs \
"

bioclite_packages="\
    Biobase \
    OmicCircos \
    GEOquery \
    affy \
    gpls \
    hopach \
    limma \
    mouse4302cdf \
    mouse4302.db \
    xcms \
"


# might need to install libpng12-dev for ggmap package

${installdir}/r-install-pkg.sh -a bootstrap -R ${VERSION}

for cranpkg in ${cran_packages}
do
    ${installdir}/r-install-pkg.sh -a install_cran -R ${VERSION} ${cranpkg};
done
unset cranpkg


for ghpkg in ${github_packages}
do
    ${installdir}/r-install-pkg.sh -a install_github -R ${VERSION} ${ghpkg};
done
unset ghpkg


for biocpkg in ${bioclite_packages}
do
    ${installdir}/r-install-pkg.sh -a install_bioc -R ${VERSION} ${biocpkg};
done
unset biocpkg

