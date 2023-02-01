#! /usr/bin/env bash

# Register the calling ec2 instance with its ALB TargetGroup
#
# Retrieves TargetGroup name from SSM ParameterStore based on the resource tags
# of the calling instance.  This param must be staged in advance.
#
# Usage:
#   ec2-tg-register.sh

# Source awscli shell functions
[ -f ~/.profile.d/ssm_functions.sh ] && . ~/.profile.d/ssm_functions.sh
[ -f ~/.profile.d/elbv2_functions.sh ] && . ~/.profile.d/elbv2_functions.sh
if [ ! -n "$AWS_DEFAULT_REGION" ]; then
  echo "Environment var AWS_DEFAULT_REGION is not set."
  exit 1
fi

# Get TargetGroup name from SSM ParameterStore
SSM_PATH=$(ssm-path-from-tags)
TG_NAME=$(aws ssm get-parameter --name ${SSM_PATH}/target-group-name | jq -r '.Parameter.Value')
if [ ! -n "$TG_NAME" ]; then
  echo "SSM parameter ${SSM_PATH}/target-group-name not found"
  exit 1
fi


# Run elbv2 command
INSTANCE_ID=$(ec2-metadata -i | awk '{print $2}')
aws elbv2 register-targets --target-group-arn $(elb-tg-show-arn $TG_NAME) --targets Id=$INSTANCE_ID

