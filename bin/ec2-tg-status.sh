#! /usr/bin/env bash

[ -f ../.profile.d/ssm_functions.sh ] && . ../.profile.d/ssm_functions.sh
[ -f ../.profile.d/elbv2_functions.sh ] && . ../.profile.d/elbv2_functions.sh

# Get TargetGroup name from SSM ParameterStore
SSM_PATH=$(ssm-path-from-tags)
TG_NAME=$(aws ssm get-parameter --name ${SSM_PATH}/target-group-name | jq -r '.Parameter.Value')

# Report status
elb-tg-health $TG_NAME

