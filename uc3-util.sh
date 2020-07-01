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
  val=`aws ssm get-parameter --name "${SSMPATH}" --region ${REGION} | jq -r '.Parameter' | jq -r '.Value'`
  [ $val ] || die "Parameter ${SSMPATH} not found"
  echo $val
}

get_ssm_json_by_path() {
  check_ssm_root
  P=$1
  SSMPATH="${SSM_ROOT_PATH}${P}"
  SSMJSON=`aws ssm get-parameters-by-path --recursive --path "${SSMPATH}" --region ${REGION} | jq -r '.Parameters'`
}

get_value_from_ssm_json() {
  P=$1
  SSMPATH="${SSM_ROOT_PATH}${P}"
  val=`echo ${SSMJSON} | jq '.[] | select(.Name=="${SSMPATH}")' | jq -r .Value`
  [ $val ] || die "Parameter ${SSMPATH} not found"
  echo $val
}
