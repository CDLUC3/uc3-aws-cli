# query functions for AWS EventBridge resources

scheduler-list-schedules() {
  $AWSBIN scheduler list-schedules | yq -r '.Schedules[].Name'
}

scheduler-show-schedule() {
  NAME=$1
  $AWSBIN scheduler get-schedule --name $NAME
}
