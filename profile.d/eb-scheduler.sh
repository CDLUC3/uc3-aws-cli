# Query functions for EventBright Scheduler resources
#
eb-schedule-list () {
  $AWSBIN scheduler list-schedules | yq -r .Schedules[].Name
}

eb-schedule-show () {
  NAME=$1
  $AWSBIN scheduler get-schedule --name $NAME
}

