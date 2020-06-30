#!/bin/bash
REGION=us-west-2

die() { echo "$*" 1>&2 ; exit 1; }

check_ssm_root() {
  [ $SSM_ROOT_PATH ] || die 'SSM_ROOT_PATH must be set'
}

get_ssm_value_by_name() {
  check_ssm_root
  PATH="${SSM_ROOT_PATH}${1}"
  `aws ssm get-parameter --name $PATH --region ${REGION} | jq -r '.Parameter' | jq -r '.Value'`
}
