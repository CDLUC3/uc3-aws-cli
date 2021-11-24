#! /usr/bin/env bash

# Deregister the calling ec2 instance from its ALB TargetGroup
#
# Retrieves TargetGroup name from SSM ParameterStore based on the resource tags
# of the calling instance.  This param must be staged in advance.
#
# Usage:
#   ec2-tg-deregister.sh

# Source awscli shell functions
[ -f ../.profile.d/ssm_functions.sh ] && . ../.profile.d/ssm_functions.sh
[ -f ../.profile.d/elbv2_functions.sh ] && . ../.profile.d/elbv2_functions.sh

# Get TargetGroup name from SSM ParameterStore
SSM_PATH=$(ssm-path-from-tags)
TG_NAME=$(aws ssm get-parameter --name ${SSM_PATH}/target-group-name | jq -r '.Parameter.Value')

# Run elbv2 command
INSTANCE_ID=$(ec2-metadata -i | awk '{print $2}')
aws elbv2 deregister-targets --region $REGION --target-group-arn $(elb-tg-show-arn $TG_NAME) --targets Id=$INSTANCE_ID

