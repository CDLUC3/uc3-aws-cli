#!/bin/bash
REGION=us-west-2

die() { echo "$*" 1>&2 ; exit 1; }

check_ssm_root() {
  [ $SSM_ROOT_PATH ] || die 'SSM_ROOT_PATH must be set'
}

get_ssm_value_by_name() {
  check_ssm_root
  P=$1
  SSMPATH="${SSM_ROOT_PATH}${P}"
  echo "Retrieving Parameter ${SSMPATH}"
  val=`aws ssm get-parameter --name "${SSMPATH}" --region ${REGION} | jq -r '.Parameter' | jq -r '.Value'`
  [ $val ] || die "Parameter ${SSM_DB_PATH} not found"
  echo $val
}
