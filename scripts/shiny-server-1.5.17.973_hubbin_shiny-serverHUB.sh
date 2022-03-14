#!/bin/sh

if [ $# -ne 1 ] ; then
   echo "Usage: $0 shinyToolPath"
   exit 64
fi

shinyToolPath=$1

if [ ! -e ${shinyToolPath} ] ; then
   echo "${shinyToolPath} does not exist"
   exit 1
fi
if [ ! -d ${shinyToolPath} ] ; then
   echo "${shinyToolPath} is not a directory"
   exit 1
fi

hubBinPath=$(readlink -f $(dirname $0))
binPath=${hubBinPath}/../shiny-server/bin

serverTmpPath=${SESSIONDIR}/shiny-server

binDir=$(readlink -f $(dirname $0)/../shiny-server/bin)

mkdir -p ${serverTmpPath}

cat > ${serverTmpPath}/shiny-server.conf << EOF
run_as ${USER};
#preserve_logs true;

# Define a server that listens on port 8001
server {
  listen 8001 127.0.0.1;

  # Define a location at the base URL
  location / {

    # Host the directory of Shiny Apps stored in this directory
    app_dir ${shinyToolPath};
    app_idle_timeout 0;

    # Log all Shiny output to files in this directory
    log_dir ${serverTmpPath}/log;
    bookmark_state_dir ${serverTmpPath}/bookmarks;
  }
}
EOF

#export SHINY_LOG_LEVEL=TRACE

${binDir}/shiny-server ${serverTmpPath}/shiny-server.conf
