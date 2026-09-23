# query functions for AWS EventBridge resources

scheduler-schedule-list() {
  $AWSBIN scheduler list-schedules | yq -r '.Schedules[].Name'
}

scheduler-schedule-show() {
  NAME=$1
  $AWSBIN scheduler get-schedule --name $NAME
}
