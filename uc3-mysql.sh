#!/bin/bash

source uc3-util.sh

check_ssm_root
[ $SSM_DB_NAME ] || die 'SSM_DB_NAME must be set'

dbname=`get_ssm_value_by_name ${SSM_DB_NAME}/db-name`
dbhost=`get_ssm_value_by_name ${SSM_DB_NAME}/db-host`
dbuser=`get_ssm_value_by_name "${SSM_DB_NAME}/${SSM_DB_ROLE:-readonly}/db-user"`
dbpass=`get_ssm_value_by_name "${SSM_DB_NAME}/${SSM_DB_ROLE:-readonly}/db-password"`

export MYSQL_PWD=$dbpass

mysql --host=${dbhost} --port=3306 --database=${dbname} --user=${dbuser}
