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
  val=`echo ${SSMJSON} | jq ".[] | select(.Name==\"${SSMPATH}\")" | jq -r .Value`
  [ $val ] || die "Parameter ${SSMPATH} not found"
  echo $val
}

get_value_from_tag_json() {
  P=$1
  val=`echo ${TAGJSON} | jq ".[] | select(.Key==\"${P}\")" | jq -r .Value`
  [ $val ] || die "Parameter ${P} not found"
  echo $val
}

get_instance() {
  # Connect to the magic URL that provides EC2 metadata...
  curl -s "http://169.254.169.254/latest/meta-data/instance-id"
}

get_ec2_tags() {
  instance=`get_instance`
  aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=${instance}| jq -r '.Tags'"
}

create_ssm_path_from_tags() {
  TAGJSON=`get_ec2_tags`
  PROGRAM=`get_value_from_tag_json Program`
  SERVICE=`get_value_from_tag_json Service`
  ENVIRONMENT=`get_value_from_tag_json Environment`
  SSM_ROOT_PATH="/${PROGRAM}/${SERVICE}/${ENVIRONMENT}/"
}
