# AWS Cognito-idp functions
#
#

cognito-userpool-list() {
  $AWSBIN cognito-idp list-user-pools --max-results 50 | yq -r '.UserPools[].Name'
}

cognito-userpool-show-id() {
  POOLNAME=$1
  $AWSBIN cognito-idp list-user-pools --max-results 50 | \
    yq -r ".UserPools[] | select(.Name == \"${POOLNAME}\").Id"
}


cognito-userpool-show() {
  POOLNAME=$1
  ID=$(cognito-userpool-show-id $POOLNAME)
  $AWSBIN cognito-idp describe-user-pool --user-pool-id $ID
}

cognito-client-list() {
  POOLNAME=$1
  ID=$(cognito-userpool-show-id $POOLNAME)
  $AWSBIN cognito-idp list-user-pool-clients --user-pool-id $ID
}

cognito-client-show() {
  POOLNAME=$1
  CLIENT_ID=$2
  ID=$(cognito-userpool-show-id $POOLNAME)
  $AWSBIN cognito-idp describe-user-pool-client --user-pool-id $ID --client-id $CLIENT_ID
}

cognito-client-auth() {
  POOLNAME=$1
  CLIENT_ID=$2
  USERNAME=$3
  PASSWORD=$4
  #AUTH_FLOW=ADMIN_USER_PASSWORD_AUTH
  AUTH_FLOW=ADMIN_NO_SRP_AUTH

  ID=$(cognito-userpool-show-id $POOLNAME)
  $AWSBIN cognito-idp admin-initiate-auth --user-pool-id $ID --client-id $CLIENT_ID \
    --auth-flow $AUTH_FLOW --auth-parameters USERNAME=$USERNAME,PASSWORD=$PASSWORD
}

cognito-user-list() {
  POOLNAME=$1
  ID=$(cognito-userpool-show-id $POOLNAME)
  $AWSBIN cognito-idp list-users --user-pool-id $ID | \
    yq -r ".Users[].Username"
}


cognito-user-show() {
  POOLNAME=$1
  USERNAME=$2
  ID=$(cognito-userpool-show-id $POOLNAME)
  $AWSBIN cognito-idp admin-get-user --user-pool-id $ID --username $USERNAME
}

cognito-user-set-password() {
  POOLNAME=$1
  USERNAME=$2
  PASSWORD=$3
  ID=$(cognito-userpool-show-id $POOLNAME)
  $AWSBIN cognito-idp admin-set-user-password \
    --user-pool-id $ID --username $USERNAME --password $PASSWORD --permanent
}
