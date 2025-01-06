rds-db-list() {
  $AWSBIN rds  describe-db-instances | yq -r '.DBInstances[].DBInstanceIdentifier'
}

rds-db-show() {
  DB_NAME=$1
  $AWSBIN rds describe-db-instances --db-instance-identifier $DB_NAME | yq -ry .
}

rds-db-show-arn() {
  DB_NAME=$1
  $AWSBIN rds describe-db-instances --db-instance-identifier $DB_NAME | yq -r '.DBInstances[].DBInstanceArn'
}

rds-db-show-fqdn() {
  DB_NAME=$1
  $AWSBIN rds describe-db-instances --db-instance-identifier $DB_NAME | yq -r '.DBInstances[].Endpoint.Address'
}

rds-db-show-tags() {
  DB_NAME=$1
  $AWSBIN rds list-tags-for-resource --resource-name $(rds-db-show-arn $DB_NAME) | yq -ry .
}
