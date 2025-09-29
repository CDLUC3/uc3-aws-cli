

dynamo_table_list() {
  $AWSBIN dynamodb list-tables | yq -r '.TableNames[]'
}

dynamo_table_show() {
  TABLE_NAME=$1
  $AWSBIN dynamodb describe-table --table-name $TABLE_NAME
}


dynamo_table_delete() {
  TABLE_NAME=$1
  $AWSBIN dynamodb delete-table --table-name $TABLE_NAME
}


