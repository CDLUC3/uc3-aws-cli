# query functions for ECS

# 1023  aws ecs list-task-definitions 
# 1024  aws ecs help
# 1025  aws ecs describe-task-definition help
# 1026  aws ecs describe-task-definition --task-definition arn:aws:ecs:us-west-2:671846987296:task-definition/dmp-tool-dev-ecs-nextJS-apollo-server:40
#

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
  else
    for CLUSTER_NAME in $(ecs-cluster-list); do
      echo "${CLUSTER_NAME}:"
      $AWSBIN ecs list-services --cluster $CLUSTER_NAME | yq -r '.serviceArns[]' | awk -F '/' '{print "  " $3}'
      echo
    done
  fi
}

ecs-service-show-arn() {
  if [ $# -eq 0 ]; then
    echo "Usage: ecs-service-show-arn <service name>"
  else  
    SERVICE_NAME=$1
    for CLUSTER_NAME in $(ecs-cluster-list); do
      $AWSBIN ecs list-services --cluster $CLUSTER_NAME | yq -r '.serviceArns[]' | grep $SERVICE_NAME
    done
  fi
}

ecs-service-show() {
  if [ $# -eq 0 ]; then
    echo "Usage: ecs-service-show <service name>"
  else  
    SERVICE_NAME=$1
    SERVICE_ARN=$(ecs-service-show-arn $SERVICE_NAME)
    CLUSTER_NAME=$(echo $SERVICE_ARN | awk -F '/' '{print $2}')
    $AWSBIN ecs describe-services --cluster $CLUSTER_NAME --service $SERVICE_NAME  | yq -ry 'del(.services[].events)'
  fi
}

ecs-service-show-events() {
  if [ $# -eq 0 ]; then
    echo "Usage: ecs-service-show <service name>"
  else  
    SERVICE_NAME=$1
    SERVICE_ARN=$(ecs-service-show-arn $SERVICE_NAME)
    CLUSTER_NAME=$(echo $SERVICE_ARN | awk -F '/' '{print $2}')
    $AWSBIN ecs describe-services --cluster $CLUSTER_NAME --service $SERVICE_NAME  | yq -ry '.services[].events'
  fi
}

ecs-service-update() {
  SERVICE_NAME=$1
  SERVICE_ARN=$(ecs-service-show-arn $SERVICE_NAME)
  CLUSTER_NAME=$(echo $SERVICE_ARN | awk -F '/' '{print $2}')
  $AWSBIN ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force-new-deployment  | yq -ry 'del(.services[].events)'

#aws ecs update-service --cluster dmp-tool-dev-ecs-cluster-Fargate --service dmp-tool-dev-ecs-apollo --force-new-deployment

ecs-taskdef-for-service-show-arn() {
  if [ $# -eq 0 ]; then
    echo "Usage: ecs-service-show <service name>"
  else  
    SERVICE_NAME=$1
    SERVICE_ARN=$(ecs-service-show-arn $SERVICE_NAME)
    CLUSTER_NAME=$(echo $SERVICE_ARN | awk -F '/' '{print $2}')
    $AWSBIN ecs describe-services --cluster $CLUSTER_NAME --service $SERVICE_NAME  | yq -r '.services[].deployments[].taskDefinition'
  fi
}

ecs-taskdef-for-service-show() {
  SERVICE_NAME=$1
  $AWSBIN ecs describe-task-definition --task-definition $(ecs-taskdef-for-service-show-arn $SERVICE_NAME)
}
