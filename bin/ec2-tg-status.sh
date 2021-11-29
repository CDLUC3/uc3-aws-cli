#! /usr/bin/env bash

# Display Target health for the ALB TargetGroup the calling instance belongs to.
#
# Retrieves TargetGroup name from SSM ParameterStore based on the resource tags
# of the calling instance.  This param must be staged in advance.
#
# Usage:
#   ec2-tg-status.sh

# Source awscli shell functions
[ -f ~/.profile.d/ssm_functions.sh ] && . ~/.profile.d/ssm_functions.sh
[ -f ~/.profile.d/elbv2_functions.sh ] && . ~/.profile.d/elbv2_functions.sh

# Get TargetGroup name from SSM ParameterStore
set +x
SSM_PATH=$(ssm-path-from-tags)
TG_NAME=$(aws ssm get-parameter --name ${SSM_PATH}/target-group-name | jq -r '.Parameter.Value')
if [ ! -n "$TG_NAME" ]; then
  echo "SSM parameter ${SSM_PATH}/target-group-name not found"
  exit 1
fi

# Report status
elb-tg-health $TG_NAME

