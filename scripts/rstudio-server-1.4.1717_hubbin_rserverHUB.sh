#!/bin/sh

hubBinPath=$(readlink -f $(dirname $0))
binPath=${hubBinPath}/../bin

serverTmpPath=${SESSIONDIR}/rstudio-server
serverDBPath=${serverTmpPath}/DB

rm -rf ${serverTmpPath}
mkdir -p ${serverDBPath}

cat > ${serverTmpPath}/rstudio-server.dbconf << EOF
provider=sqlite
directory=${serverDBPath}
EOF

rm -rf ${serverTmpPath}/rstudio-server.conf
cat > ${serverTmpPath}/rstudio-server.conf << EOF
#server-access-log=1
EOF

#echo "${binPath}/rserver --auth-none 0 --auth-timeout-minutes 0 "                               >> ${serverTmpPath}/rserverHUB.log
#echo "                   --auth-validate-users 1 --auth-encrypt-password 0 "                    >> ${serverTmpPath}/rserverHUB.log
#echo "                   --auth-pam-helper-path ${hubBinPath}/rstudioUserAuthentication.sh "    >> ${serverTmpPath}/rserverHUB.log
#echo "                   --server-working-dir ${HOME} --server-user ${USER} "                   >> ${serverTmpPath}/rserverHUB.log
#echo "                   --www-port 8001 --server-pid-file ${serverTmpPath}/rstudio-server.pid ">> ${serverTmpPath}/rserverHUB.log
#echo "                   --server-data-dir ${serverTmpPath} "                                   >> ${serverTmpPath}/rserverHUB.log
#echo "                   --database-config-file ${serverTmpPath}/rstudio-server.dbconf "        >> ${serverTmpPath}/rserverHUB.log
#echo "                   --config-file ${serverTmpPath}/rstudio-server.conf"                    >> ${serverTmpPath}/rserverHUB.log

${binPath}/rserver --auth-none 1 --auth-timeout-minutes 0 \
                   --auth-validate-users 1 --auth-encrypt-password 0 \
                   --auth-pam-helper-path ${hubBinPath}/rstudioUserAuthentication.sh \
                   --server-working-dir ${HOME} --server-user ${USER} \
                   --www-port 8001 --server-pid-file ${serverTmpPath}/rstudio-server.pid \
                   --server-data-dir ${serverTmpPath} \
                   --database-config-file ${serverTmpPath}/rstudio-server.dbconf \
                   --config-file ${serverTmpPath}/rstudio-server.conf
