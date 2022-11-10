echo "******************************************************************************"
echo "ORDS Software Installation." `date`
echo "******************************************************************************"
echo "Create docker_fg group and ords user."
groupadd -g 1042 docker_fg
useradd ords -u 501 -G docker_fg

echo "Java setup."
mkdir -p /u01/java
cd /u01/java
tar -xzf ${SOFTWARE_DIR}/${JAVA_SOFTWARE}
rm -f ${SOFTWARE_DIR}/${JAVA_SOFTWARE}
TEMP_FILE=`ls`
ln -s ${TEMP_FILE} latest

echo "ORDS setup."
mkdir -p ${ORDS_HOME}
cd ${ORDS_HOME}
unzip -oq ${SOFTWARE_DIR}/${ORDS_SOFTWARE}
rm -f ${SOFTWARE_DIR}/${ORDS_SOFTWARE}
mkdir -p ${ORDS_CONF}/logs

echo "SQLcl setup."
cd /u01
unzip -oq ${SOFTWARE_DIR}/${SQLCL_SOFTWARE}
rm -f ${SOFTWARE_DIR}/${SQLCL_SOFTWARE}

echo "Set file permissions."
chmod u+x ${SCRIPTS_DIR}/*.sh
chown -R ords:ords /u01

touch /history.log
chown ords:ords /history.log
