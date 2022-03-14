#!/bin/sh

exitStatus=1

if [ $# -gt 0 ] ; then
   rUserName=$1

   if [ -n "${SESSIONDIR}" ] ; then
      rserverTmpPath=${SESSIONDIR}/rstudio-server
      mkdir -p ${rserverTmpPath}

      rstudioAuthLog=${rserverTmpPath}/rstudio_auth.log

      echo $0 "$@" >> ${rstudioAuthLog}

      if [ "${rUserName}" = "${USER}" ] ; then
         rserverProcess=$(ps --format ppid= $$ | tr --delete ' \n')
         rserverPath=$(readlink -f /proc/${rserverProcess}/exe)
         rserverDirectory=$(dirname ${rserverPath})
         authScriptPath=$(readlink -f $0)
         authScriptDirectory=$(dirname ${authScriptPath})
         authScriptBinDirectory=$(readlink -f ${authScriptDirectory}/../bin)

         if [ ${rserverDirectory} = ${authScriptBinDirectory} ] ; then
            echo "Path check passes" >> ${rstudioAuthLog}
            case ${rserverPath} in
               /apps/share64/*/rstudio-server/*/bin/rserver ) exitStatus=0;;
            esac
         else
            echo ${rserverProcess} >> ${rstudioAuthLog}
            ls -ls /proc/${rserverProcess}/exe >> ${rstudioAuthLog}
            echo ${rserverPath} >> ${rstudioAuthLog}
            echo ${rserverDirectory} >> ${rstudioAuthLog}
            echo ${authScriptPath} >> ${rstudioAuthLog}
            echo ${authScriptDirectory} >> ${rstudioAuthLog}
         fi
      fi
   fi
else
   if [ -n "${SESSIONDIR}" ] ; then
      rserverTmpPath=${SESSIONDIR}/rstudio-server
      mkdir -p ${rserverTmpPath}

      rstudioAuthLog=${rserverTmpPath}/rstudio_auth.log
      echo "usage: $0 userName" >> ${rstudioAuthLog}
   fi
fi

exit ${exitStatus}
