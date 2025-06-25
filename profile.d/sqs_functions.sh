# sqs functions

sqs-queue-list () {
  $AWSBIN sqs list-queues
}


sqs-queue-show () {
  QUEUE_URL=$1
  $AWSBIN sqs get-queue-attributes --queue-url $QUEUE_URL --attribute-names All
}





