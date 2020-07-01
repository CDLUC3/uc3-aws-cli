#!/bin/bash

source uc3-util.sh

check_ssm_root
[ $SSM_DB_NAME ] || die 'SSM_DB_NAME must be set'

# Option 1: get parameters one at a time

dbname=`get_ssm_value_by_name ${SSM_DB_NAME}/db-name`
dbhost=`get_ssm_value_by_name ${SSM_DB_NAME}/db-host`
dbuser=`get_ssm_value_by_name "${SSM_DB_NAME}/${SSM_DB_ROLE:-readonly}/db-user"`
dbpass=`get_ssm_value_by_name "${SSM_DB_NAME}/${SSM_DB_ROLE:-readonly}/db-password"`

export MYSQL_PWD=$dbpass

echo mysql --host=${dbhost} --port=3306 --database=${dbname} --user=${dbuser}

# Option 2: get parameters in a single API call, save to json variable

get_ssm_json_by_path "${SSM_DB_NAME}/"

echo $SSMJSON

dbname=`get_value_from_ssm_json ${SSM_DB_NAME}/db-name`
dbhost=`get_value_from_ssm_json ${SSM_DB_NAME}/db-host`
dbuser=`get_value_from_ssm_json "${SSM_DB_NAME}/${SSM_DB_ROLE:-readonly}/db-user"`
dbpass=`get_value_from_ssm_json "${SSM_DB_NAME}/${SSM_DB_ROLE:-readonly}/db-password"`

echo mysql --host=${dbhost} --port=3306 --database=${dbname} --user=${dbuser}
