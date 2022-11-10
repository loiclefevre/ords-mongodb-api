# ------------------------------------------------------------------------------
# Dockerfile to build basic Oracle REST Data Services (ORDS) images
# Based on the following:
#   - Oracle Linux 8 - Slim
#   - Java 11 :
#       https://adoptium.net/releases.html?variant=openjdk11&jvmVariant=hotspot
#   - Oracle REST Data Services (ORDS) :
#       http://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html
#   - Oracle SQLcl :
#       http://www.oracle.com/technetwork/developer-tools/sqlcl/downloads/index.html
#
# Example build and run. Assumes Docker network called "my_network" to connect to DB.
#
# docker build -t ol8_ords:latest .
# docker build --squash -t ol8_ords:latest .
# Podman
# docker build --format docker --no-cache -t ol8_ords:latest .
#
# docker run -dit --name ol8_ords_con -p 27017:27017 -p 8080:8080 -p 8443:8443 --network=my_network -e DB_HOSTNAME=ol8_19_con ol8_ords:latest
#
# docker logs --follow ol8_ords_con
# docker exec -it ol8_ords_con bash
#
# docker stop --time=30 ol8_ords_con
# docker start ol8_ords_con
#
# docker rm -vf ol8_ords_con
#
# ------------------------------------------------------------------------------

# Set the base image to Oracle Linux 8
FROM oraclelinux:8-slim

# File Author / Maintainer
LABEL maintainer="loic.lefevre@oracle.com"

# ------------------------------------------------------------------------------
# Define fixed (build time) environment variables.
ENV JAVA_SOFTWARE="jdk-11.0.16.1_linux-x64_bin.tar.gz"                         \
    ORDS_SOFTWARE="ords-latest.zip"                                            \
    SQLCL_SOFTWARE="sqlcl-latest.zip"                                          \
    SOFTWARE_DIR="/u01/software"                                               \
    SCRIPTS_DIR="/u01/scripts"                                                 \
    KEYSTORE_DIR="/u01/keystore"                                               \
    ORDS_HOME="/u01/ords"                                                      \
    ORDS_CONF="/u01/config/ords"                                               \
    JAVA_HOME="/u01/java/latest"                                               

# ------------------------------------------------------------------------------
# Define config (runtime) environment variables.
ENV DB_HOSTNAME="ol8-19.localdomain"                                           \
    DB_PORT="1521"                                                             \
    DB_SERVICE="pdb1"                                                          \
    ORDS_PUBLIC_USER_PASSWORD="OrdsPassword1"                                  \
    ORDS_LISTENER_PASSWORD="OrdsPassword1"                                     \
    TEMP_TABLESPACE="TEMP"                                                     \
    SYS_PASSWORD="SysPassword1"                                                \
    KEYSTORE_PASSWORD="KeystorePassword1"                                      \
    AJP_SECRET="AJPSecret1"                                                    \
    AJP_ADDRESS="::1"                                                          \
    PROXY_IPS=""                                                               \
    JAVA_OPTS="-Dconfig.url=${ORDS_CONF} -Xms1024M -Xmx1024M"


# ------------------------------------------------------------------------------
# Get all the files for the build.
COPY software/* ${SOFTWARE_DIR}/
COPY scripts/* ${SCRIPTS_DIR}/

# ------------------------------------------------------------------------------
# Unpack all the software and remove the media.
# No config done in the build phase.
RUN sh ${SCRIPTS_DIR}/install_os_packages.sh                                && \
    sh ${SCRIPTS_DIR}/ords_software_installation.sh

# Perform the following actions as the ords user
USER ords

EXPOSE 8080 8443 27017
HEALTHCHECK --interval=1m --start-period=1m \
   CMD ${SCRIPTS_DIR}/healthcheck.sh >/dev/null || exit 1

# ------------------------------------------------------------------------------
# The start script performs all config based on runtime environment variables,
# and starts tomcat.
CMD exec ${SCRIPTS_DIR}/start.sh

# End
