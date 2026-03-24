# sqs functions

sqs-queue-list () {
  $AWSBIN sqs list-queues
}


sqs-queue-show () {
  QUEUE_URL=$1
  $AWSBIN sqs get-queue-attributes --queue-url $QUEUE_URL --attribute-names All
}



# aws sqs receive-message --queue-url https://sqs.us-west-2.amazonaws.com/671846987296/uc3-ops-logstash-demo-pipeline-queue
# aws sqs send-message --queue-url https://sqs.us-west-2.amazonaws.com/671846987296/uc3-ops-logstash-demo-pipeline-queue --message-body "hello world from blee"


