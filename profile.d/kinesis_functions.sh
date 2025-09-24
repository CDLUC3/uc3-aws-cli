# AWS Kinesis and Firehose query functions

kinesis-stream-list() {
  $AWSBIN kinesis list-streams | yq -r '.StreamNames[]'
}   
  
kinesis-stream-show() {
  STREAM_NAME=$1
  STREAM_MODE=$($AWSBIN kinesis list-streams | yq -ry ".StreamSummaries[] | select(.StreamName == \"$STREAM_NAME\") | .StreamModeDetails")
  $AWSBIN kinesis describe-stream --stream-name $STREAM_NAME
  echo -e "  StreamModeDetails:\n    $STREAM_MODE"
}     


kinesis-stream-summary-summary() {
  STREAM_NAME=$1
  $AWSBIN kinesis list-streams | yq -ry ".StreamSummaries[] | select(.StreamName == \"$STREAM_NAME\") | ."

}




#aws kinesis get-shard-iterator --stream-name RootAccess --shard-id shardId-000000000000 --shard-iterator-type TRIM_HORIZON
#
#aws kinesis get-records --limit 10 --shard-iterator "AAAAAAAAAAFGU/kLvNggvndHq2UIFOw5PZc6F01s3e3afsSscRM70JSbjIefg2ub07nk1y6CDxYR1UoGHJNP4m4NFUetzfL+wev+e2P4djJg4L9wmXKvQYoE+rMUiFq+p4Cn3IgvqOb5dRA0yybNdRcdzvnC35KQANoHzzahKdRGb9v4scv+3vaq+f+OIK8zM5My8ID+g6rMo7UKWeI4+IWiK2OSh0uP"
#
#
#echo -n "<Content of Data>" | base64 -d | zcat


kinesis-stream-show-shard-iterater() {
  STREAM_NAME=$1
  $AWSBIN kinesis get-shard-iterator --stream-name $STREAM_NAME --shard-id shardId-000000000000 --shard-iterator-type TRIM_HORIZON | yq -r '.ShardIterator'
}


kinesis-stream-show-records() {
  STREAM_NAME=$1
  SHARD_ITERATER=$(kinesis-stream-show-shard-iterater $STREAM_NAME)
  DATA_CONTENT=$($AWSBIN kinesis get-records --limit 10 --shard-iterator "$SHARD_ITERATER" | yq -r '.Records[].Data')
  echo -n "$DATA_CONTENT" | base64 -d | zcat
}

# kinesis-stream-show-records uc3-ops-log-kinesis-stream-06798730 | json2yaml.py |less



firehose-stream-list() {
    $AWSBIN firehose list-delivery-streams | yq -r '.DeliveryStreamNames[]'
}

firehose-stream-show() {
    STREAM_NAME=$1
    $AWSBIN firehose describe-delivery-stream --delivery-stream-name $STREAM_NAME
}
