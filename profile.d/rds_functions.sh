rds-db-list() {
  aws rds  describe-db-instances | jq -r '.DBInstances[].DBInstanceIdentifier'
}

rds-db-show() {
  DB_NAME=$1
  aws rds describe-db-instances --db-instance-identifier $DB_NAME
}

rds-db-show-arn() {
  DB_NAME=$1
  aws rds describe-db-instances --db-instance-identifier $DB_NAME | jq -r '.DBInstances[].DBInstanceArn'
}

rds-db-show-fqdn() {
  DB_NAME=$1
  aws rds describe-db-instances --db-instance-identifier $DB_NAME | jq -r '.DBInstances[].Endpoint.Address'
}

rds-db-show-tags() {
  DB_NAME=$1
  aws rds list-tags-for-resource --resource-name $(rds-db-show-arn $DB_NAME)
}
