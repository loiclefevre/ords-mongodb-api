#!/bin/sh
echo "Downloading Oracle REST Data Services latest..."
curl -G -# https://download.oracle.com/otn_software/java/ords/ords-latest.zip -o software/ords-latest.zip
echo "Downloading Oracle SQLcl..."
curl -G -# https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip -o software/sqlcl-latest.zip

