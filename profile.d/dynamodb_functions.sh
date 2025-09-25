

dynamo_table_list() {
  $AWSBIN dynamodb list-tables | yq -r '.TableNames[]'
}

dynamo_table_show() {
  TABLE_NAME=$1
  $AWSBIN dynamodb describe-table --table-name $TABLE_NAME
}


# aws dynamodb delete-table --table-name logstash
