#!/bin/bash

source uc3-util.sh

check_ssm_root

echo " -- Environment Variables --"
echo "SSM_ROOT_PATH: ${SSM_ROOT_PATH}"
echo "SSM_DB_NAME:   ${SSM_DB_NAME:-inv}"
echo "SSM_DB_ROLE:   ${SSM_DB_ROLE:-readonly}"

DB_NAME=${1:-${SSM_DB_NAME:-inv}}
DB_ROLE=${2:-${SSM_DB_ROLE:-readonly}}

echo ""
echo " -- Overlay command line parameters --"
echo "DB_NAME:       ${DB_NAME}"
echo "DB_ROLE:       ${DB_ROLE}"

# Option 1: get parameters one at a time

# dbname=`get_ssm_value_by_name ${SSM_DB_NAME}/db-name`
# dbhost=`get_ssm_value_by_name ${SSM_DB_NAME}/db-host`
# dbuser=`get_ssm_value_by_name "${SSM_DB_NAME}/${SSM_DB_ROLE:-readonly}/db-user"`
# dbpass=`get_ssm_value_by_name "${SSM_DB_NAME}/${SSM_DB_ROLE:-readonly}/db-password"`

# export MYSQL_PWD=$dbpass

# mysql --host=${dbhost} --port=3306 --database=${dbname} --user=${dbuser}

# Option 2: get parameters in a single API call, save to json variable

get_ssm_json_by_path "${DB_NAME}/"

dbname=`get_value_from_ssm_json ${DB_NAME}/db-name`
dbhost=`get_value_from_ssm_json ${DB_NAME}/db-host`
dbuser=`get_value_from_ssm_json "${DB_NAME}/${DB_ROLE}/db-user"`
dbpass=`get_value_from_ssm_json "${DB_NAME}/${DB_ROLE}/db-password"`

export MYSQL_PWD=$dbpass

mysql --host=${dbhost} --port=3306 --database=${dbname} --user=${dbuser}
