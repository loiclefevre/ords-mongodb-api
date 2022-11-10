#!/bin/sh

echo "******************************************************************************"
echo "Check if this is the first run." `date`
echo "******************************************************************************"
FIRST_RUN="false"
if [ ! -f ~/CONTAINER_ALREADY_STARTED_FLAG ]; then
  echo "First run."
  FIRST_RUN="true"
  touch ~/CONTAINER_ALREADY_STARTED_FLAG
else
  echo "Not first run."
fi

echo "******************************************************************************"
echo "Check DB is available." `date`
echo "******************************************************************************"
export PATH=${PATH}:${JAVA_HOME}/bin

function check_db {
  #echo "Checking DB: $* ..."
  CONNECTION=$*
  RETVAL=`/u01/sqlcl/bin/sql -silent ${CONNECTION} <<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF TAB OFF
alter user ORDS_PUBLIC_USER identified by ${SYS_PASSWORD};
SELECT 'Alive' FROM dual;
EXIT;
EOF`

  RETVAL="${RETVAL//[$'\t\r\n']}"
  if [ "${RETVAL}" = "Alive" ]; then
    DB_OK=0
  else
    DB_OK=1
  fi
}

CONNECTION="SYS/${SYS_PASSWORD}@//${DB_HOSTNAME}:${DB_PORT}/${DB_SERVICE} AS SYSDBA"
check_db ${CONNECTION}
while [ ${DB_OK} -eq 1 ]
do
  echo "DB not available yet. Waiting for 2 seconds."
  sleep 2
  check_db ${CONNECTION}
done

if [ "${FIRST_RUN}" == "true" ]; then
  echo "******************************************************************************"
  echo "Configure ORDS. Safe to run on DB with existing config." `date`
  echo "******************************************************************************"
  cd ${ORDS_HOME}

  export ORDS_CONFIG=${ORDS_CONF}
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} install \
       --log-folder ${ORDS_CONF}/logs \
       --admin-user SYS \
       --db-hostname ${DB_HOSTNAME} \
       --db-port ${DB_PORT} \
       --db-servicename ${DB_SERVICE} \
       --proxy-user \
       --feature-db-api true \
       --feature-rest-enabled-sql true \
       --feature-sdw true \
       --password-stdin <<EOF
${SYS_PASSWORD}
${SYS_PASSWORD}
EOF

  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} config set mongo.enabled true
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} config set standalone.http.port 8080
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} config set jdbc.MaxConnectionReuseCount 5000
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} config set jdbc.MaxConnectionReuseTime 900
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} config set jdbc.SecondsToTrustIdleConnection 1
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} config set jdbc.InitialLimit 20
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} config set jdbc.MaxLimit 20

fi

echo "******************************************************************************"
exec "${ORDS_HOME}/bin/ords" --config ${ORDS_CONF} serve

bgPID=$!
wait $bgPID
