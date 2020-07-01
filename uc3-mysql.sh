#!/bin/bash

source uc3-util.sh

check_ssm_root
[ $SSM_DB_NAME ] || die 'SSM_DB_NAME must be set'

dbname=`get_ssm_value_by_name ${SSM_DB_NAME}/db-name`
dbhost=`get_ssm_value_by_name ${SSM_DB_NAME}/db-host`
dbuser=`get_ssm_value_by_name "${SSM_DB_NAME}/${SSM_DB_ROLE:readonly}/db-user"`

echo "${dbhost} ${dbname} ${dbuser} "
