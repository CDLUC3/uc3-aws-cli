#!/bin/bash

# Pre-requisites
# - set SSM_ROOT_PATH
# - set SSM_DB_NAME (opt)
# - set SSM_DB_ROLE (opt)
# - create SSM_PARAMETERS
#   - ${SSM_ROOT_PATH}/${SSM_DB_NAME}/db-host
#   - ${SSM_ROOT_PATH}/${SSM_DB_NAME}/db-name
#   - ${SSM_ROOT_PATH}/${SSM_DB_NAME}/${SSM_DB_ROLE}/db-user
#   - ${SSM_ROOT_PATH}/${SSM_DB_NAME}/${SSM_DB_ROLE}/db-password
#
# Usage:
#   uc3-mysqldump.sh [db_name] [db_role] [-debug] -- [params to pass to mysql]

EXIT_ON_DIE=true
source ~/.profile.d/uc3-aws-util.sh

create_ssm_path_from_tags
check_ssm_root

DEBUG=false
DB_NAME=""
DB_ROLE=""
count=0

# see https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
while (( "$#" )); do
  case "$1" in
    -debug)
      DEBUG=true
      shift
      ;;
    -help | --help | -h)
      echo "Usage:"
      echo "  uc3-mysql.sh [db_name] [db_role] [-debug] [-rp SSM_ROOT_PATH] -- [params to pass to mysql]"
      echo ""
      echo "  For the dba account, use -rp /PROGRAM/SERVICE/ENVIRONMENT-ops/"
      echo ""
      create_ssm_path_from_tags
      echo "  Current SSM_ROOT_PATH=${SSM_ROOT_PATH}"
      echo "  Use -rp /PROGRAM/SERVICE/ENVIRONMENT/" to override value
      exit
      ;;
    -rp)
      shift
      SSM_ROOT_PATH=$1
      shift
      ;;
    --)
      shift
      break
      ;;
    *) # preserve positional arguments
      case $count in
        0)
          DB_NAME=$1
          count=$((count + 1))
          shift
          ;;
        1)
          DB_ROLE=$1
          count=$((count + 1))
          shift
          ;;
        *)
          shift
          ;;
      esac
  esac
done

DB_NAME=${DB_NAME:-${SSM_DB_NAME:-inv}}
DB_ROLE=${DB_ROLE:-${SSM_DB_ROLE:-readonly}}


if ($DEBUG)
then
  echo " -- Environment Variables --"
  echo "SSM_ROOT_PATH: ${SSM_ROOT_PATH}"
  echo "SSM_DB_NAME:   ${SSM_DB_NAME:-inv}"
  echo "SSM_DB_ROLE:   ${SSM_DB_ROLE:-readonly}"

  echo ""
  echo " -- Overlay command line parameters --"
  echo "DB_NAME:       ${DB_NAME}"
  echo "DB_ROLE:       ${DB_ROLE}"

  echo 'MYSQLARG: ' "$@"
fi

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

mysqldump --host=${dbhost} --port=3306 --user=${dbuser} ${dbname} "$@"
