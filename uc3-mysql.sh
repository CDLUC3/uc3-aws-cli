#!/bin/bash

source uc3-util.sh

[ $SSM_DB_PATH ] || die 'SSM_DB_PATH must be set'

get_ssm_value_by_name $SSM_DB_PATH
