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

ecs-taskdef-show-arn() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-taskdef-show-arn <cluster name> <service name>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs describe-services --cluster $CLUSTER_NAME --service $SERVICE_NAME  | yq -r '.services[].deployments[].taskDefinition'
  fi
}

ecs-taskdef-show() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-taskdef-show <cluster name> <service name>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs describe-task-definition --task-definition $(ecs-taskdef-for-service-show-arn $CLUSTER_NAME $SERVICE_NAME)
  fi
}

ecs-task-list() {
  if [ $# -eq 2 ]; then
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    $AWSBIN ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE_NAME | yq -r '.taskArns[]'
  elif [ $# -eq 1 ]; then
    CLUSTER_NAME=$1
    $AWSBIN ecs list-tasks --cluster $CLUSTER_NAME | yq -r '.taskArns[]'
  else
    echo "Usage: ecs-task-list <cluster name> <service name>"
  fi
}

# agould@localhost:~/git/github/cdluc3/uc3-aws-cli/profile.d> aws ecs describe-tasks --cluster dmp-tool-dev-ecs-cluster-Fargate --tasks arn:aws:ecs:us-west-2:671846987296:task/dmp-tool-dev-ecs-cluster-Fargate/dc57b0dc02f2465087757bf002213f1d| json2yaml.py |less
ecs-task-show() {
  if [ $# -ne 2 ]; then
    echo "Usage: ecs-taskdef-show <cluster name> <service name>"
    #echo "Usage: ecs-task-show <cluster name> <task arn>"
  else  
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    TASK_ARN=$(ecs-task-list $CLUSTER_NAME $SERVICE_NAME)
    $AWSBIN ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARN
  fi
}

