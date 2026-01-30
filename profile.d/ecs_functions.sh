# query functions for ECS


ecs-cluster-list() {
  $AWSBIN ecs list-clusters | yq -r '.clusterArns[]' | awk -F '/' '{print $2}'
}

ecs-cluster-show-arn() {
  CLUSTER_NAME=$1
  $AWSBIN ecs list-clusters | yq -r '.clusterArns[]' | grep $CLUSTER_NAME
}

ecs-cluster-show() {
  CLUSTER_NAME=$1
  CLUSTER_ARN=$(ecs-cluster-show-arn $CLUSTER_NAME)
  $AWSBIN ecs describe-clusters --clusters $CLUSTER_ARN
}

ecs-cluster-show-all() {
  CLUSTER_NAME=$1
  CLUSTER_ARN=$(ecs-cluster-show-arn $CLUSTER_NAME)
  $AWSBIN ecs describe-clusters --clusters $CLUSTER_ARN --include ATTACHMENTS CONFIGURATIONS SETTINGS STATISTICS TAGS
}


ecs-service-list() {
  if [ $# -gt 0 ]; then
    CLUSTER_NAME=$1
    $AWSBIN ecs list-services --cluster $CLUSTER_NAME | yq -r '.serviceArns[]' | awk -F '/' '{print $3}'
  elif [ $# -eq 0 ]; then
    for CLUSTER_NAME in $(ecs-cluster-list); do
      echo "${CLUSTER_NAME}:"
      $AWSBIN ecs list-services --cluster $CLUSTER_NAME | yq -r '.serviceArns[]' | awk -F '/' '{print "  " $3}'
      echo
    done
  else
    echo "Usage: ecs-service-list [cluster name]"
  fi
}

ecs-service-show-arn() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-service-show-arn <cluster name> <service name>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs list-services --cluster $CLUSTER_NAME | yq -r '.serviceArns[]' | grep $SERVICE_NAME
  fi
}

ecs-service-show() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-service-show <cluster name> <service name>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs describe-services --cluster $CLUSTER_NAME --service $SERVICE_NAME  | yq -ry 'del(.services[].events)'
  fi
}

ecs-service-show-events() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-service-show-events <cluster name> <service name>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs describe-services --cluster $CLUSTER_NAME --service $SERVICE_NAME  | yq -ry '.services[].events'
  fi
}

ecs-service-update() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-service-update <cluster name> <service name>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force-new-deployment
  fi
}

# aws ecs list-task-definitions | jq -r .taskDefinitionArns[] | awk -F : '{print $6}' | awk -F / '{print $2}' | sort -u
# aws ecs list-task-definitions --family-prefix uc3-ops-ecs-dev-service-logstash-logstash
# aws ecs describe-task-definition --task-definition uc3-ops-ecs-dev-service-logstash-logstash
#

ecs-taskdef-list() {
    # must match a ecs family name exactly
    FAMILY=$1
    if [ -n "$FAMILY" ]; then
        PREFIX_QUERY="--family-prefix $FAMILY"
    else
        PREFIX_QUERY=""
    fi

    response=$(aws ecs list-task-definitions $PREFIX_QUERY)
    taskdefinitions=$(echo "$response" | jq -r '.taskDefinitionArns[]')
    nexttoken=$(echo "$response" | jq -r '.nextToken')
    #echo $nexttoken
    while [ "$nexttoken" != "null" ]; do
        response=$(aws ecs list-task-definitions --starting-token $nexttoken $PREFIX_QUERY)
        taskdefinitions="${taskdefinitions} $(echo "$response" | jq -r '.taskDefinitionArns[]')"
        nexttoken=$(echo "$response" | jq -r '.nextToken')
    done
    # convert spaces into end-of-line and sort
    echo "${taskdefinitions// /$'\n'}"
}

ecs-taskdef-show() {
  # can also be a taskdef family
  TASKDEF_ARN=$1
  $AWSBIN ecs describe-task-definition --task-definition $TASKDEF_ARN
}

ecs-taskdef-family-list() {
    # must match beginning of a ecs family name
    FAMILY_PREFIX=$1
    if [ -n "$FAMILY_PREFIX" ]; then
        PREFIX_QUERY="--family-prefix $FAMILY_PREFIX"
    else
        PREFIX_QUERY=""
    fi
    $AWSBIN ecs list-task-definition-families $PREFIX_QUERY | yq -r '.families[]'
}

ecs-taskdef-for-service-list() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-taskdef-for-service-list <cluster name> <service name>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs describe-services --cluster $CLUSTER_NAME --service $SERVICE_NAME  | yq -r '.services[].deployments[].taskDefinition'
  fi
}

ecs-taskdef-for-service-show() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-taskdef-for-service-show <cluster name> <service name>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs describe-task-definition --task-definition $(ecs-taskdef-for-service-list $CLUSTER_NAME $SERVICE_NAME)
  fi
}

ecs-task-list() {
  if [ $# -eq 2 ]; then
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE_NAME | yq -r '.taskArns[]'
  elif [ $# -eq 1 ]; then
    CLUSTER_NAME=$1
    TASKARNS=$($AWSBIN ecs list-tasks --cluster $CLUSTER_NAME | yq -r '.taskArns[]')
    $AWSBIN ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASKARNS | yq -ry '.tasks[] | {"TaskArn": .taskArn, "TaskDef": .taskDefinitionArn, "Group": .group}'
    #$AWSBIN ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASKARNS | yq -ry .

  else
    echo "Usage: ecs-task-list <cluster name> [service name]"
  fi
}

ecs-task-show() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-task-show <cluster name> <task arn>"
  else  
    CLUSTER_NAME=$1
    TASK_ARN=$2
    $AWSBIN ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARN
  fi
}

# agould@localhost:~/git/github/cdluc3/uc3-aws-cli/profile.d> aws ecs describe-tasks --cluster dmp-tool-dev-ecs-cluster-Fargate --tasks arn:aws:ecs:us-west-2:671846987296:task/dmp-tool-dev-ecs-cluster-Fargate/dc57b0dc02f2465087757bf002213f1d| json2yaml.py |less

ecs-task-for-service-show() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-task-show <cluster name> <service name>"
    #echo "Usage: ecs-task-show <cluster name> <task arn>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    TASK_ARN=$(ecs-task-list $CLUSTER_NAME $SERVICE_NAME)
    $AWSBIN ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARN
  fi
}

ecs-task-stop() {
  CLUSTER_NAME=$1
  TASK_ARN=$2
  $AWSBIN ecs stop-task --cluster $CLUSTER_NAME --task $TASK_ARN
}

ecs-task-run() {
  JSON_FILE=$1
  $AWSBIN ecs run-task --cli-input-json file://${JSON_FILE}
}

# run task using cli-input-json file
#
# > ec2-sg-show-id dmp-tool-dev-ecs-cluster-SecGrp
# sg-06e8a7ea8e04386a9
# 
# > ec2-subnet-show cdl-uc3-dev-public-2a | grep SubnetId
#    SubnetId: subnet-0d183c364b7083d8a
#
# CLUSTER=dmp-tool-dev-ecs-cluster-Fargate
# TASKDEF=dmp-tool-dev-ecs-certbot-certbot:1
# SECGROUP=sg-06e8a7ea8e04386a9
# SUBNETS=subnet-0d183c364b7083d8a
#
# aws ecs run-task --cli-input-json file://tmp/ebs.json
#
# Contents of tmp/ebs.json:
# 
# {
#    "cluster": "dmp-tool-dev-ecs-cluster-Fargate",
#    "taskDefinition": "dmp-tool-dev-ecs-certbot-certbot:1",
#    "launchType": "FARGATE",
#    "networkConfiguration":{
#         "awsvpcConfiguration":{
#             "assignPublicIp": "DISABLED",
#             "securityGroups": ["sg-06e8a7ea8e04386a9"],
#             "subnets":["subnet-0d183c364b7083d8a"]
#         }
#     }
# }

# Register task in alb targetgroup:
# elb-tg-register-ip dmp-tool-dev-alb-Certbot-TG 10.66.15.95
#
# session dmp-tool-dev-ecs-cluster-Fargate/certbot-ssm
#
# ecs-task-list dmp-tool-dev-ecs-cluster-Fargate | grep -C2 certbot
# ---
# TaskArn: arn:aws:ecs:us-west-2:671846987296:task/dmp-tool-dev-ecs-cluster-Fargate/2f0acab3e26841fcaaadb24220bc8852
# 
# elb-tg-deregister-ip dmp-tool-dev-alb-Certbot-TG 10.66.15.95
#
