#!/usr/bin/env bash

# Cognito

cognito-userpool-list () {
  aws cognito-idp list-user-pools --max-results 50 | jq -r '.UserPools[].Name'
}

cognito-userpool-get-id() {
  USERPOOLNAME=$1
  aws cognito-idp list-user-pools --max-results 50 | jq -r ".UserPools[] | select(.Name == \"$USERPOOLNAME\") | .Id"
}

cognito-userpool-show () {
  USERPOOLNAME=$1
  USERPOOLID=$(cognito-userpool-get-id $USERPOOLNAME)
  aws cognito-idp describe-user-pool --user-pool-id $USERPOOLID
}

cognito-userpool-domain-list () {
  USERPOOLNAME=$1
  USERPOOLID=$(cognito-userpool-get-id $USERPOOLNAME)
  aws cognito-idp describe-user-pool --user-pool-id $USERPOOLID | jq -r ".UserPool.Domain"
}

cognito-userpool-domain-show () {
  USERPOOLNAME=$1
  USERPOOLID=$(cognito-userpool-get-id $USERPOOLNAME)
  DOMAIN=$(aws cognito-idp describe-user-pool --user-pool-id $USERPOOLID | jq -r ".UserPool.Domain")
  aws cognito-idp describe-user-pool-domain --domain $DOMAIN
}

cognito-userpool-client-list () {
  USERPOOLNAME=$1
  USERPOOLID=$(cognito-userpool-get-id $USERPOOLNAME)
  aws cognito-idp list-user-pool-clients --user-pool-id $USERPOOLID | jq -r ".UserPoolClients[].ClientName"
}

cognito-userpool-client-get-id () {
  USERPOOLNAME=$1
  USERPOOLCLIENTNAME=$2
  USERPOOLID=$(cognito-userpool-get-id $USERPOOLNAME)
  aws cognito-idp list-user-pool-clients --user-pool-id $USERPOOLID | \
    jq -r ".UserPoolClients[] | select(.ClientName == \"$USERPOOLCLIENTNAME\") | .ClientId"
}

cognito-userpool-client-show () {
  USERPOOLNAME=$1
  USERPOOLCLIENTNAME=$2
  USERPOOLID=$(cognito-userpool-get-id $USERPOOLNAME)
  USERPOOLCLIENTID=$(cognito-userpool-client-get-id $USERPOOLNAME $USERPOOLCLIENTNAME)
  aws cognito-idp describe-user-pool-client --user-pool-id $USERPOOLID  --client-id $USERPOOLCLIENTID
}

cognito-userpool-user-list () {
  USERPOOLNAME=$1
  USERPOOLID=$(cognito-userpool-get-id $USERPOOLNAME)
  aws cognito-idp list-users --user-pool-id $USERPOOLID | json2yaml.py
}

cognito-userpool-user-show () {
  USERPOOLNAME=$1
  USERNAME=$2
  USERPOOLID=$(cognito-userpool-get-id $USERPOOLNAME)
  aws cognito-idp admin-get-user --user-pool-id $USERPOOLID --username $USERNAME
}

cognito-identitypool-list () {
  aws cognito-identity list-identity-pools --max-results 50 | jq -r ".IdentityPools[].IdentityPoolName"
}

cognito-identitypool-get-id () {
  IDPOOLNAME=$1
  aws cognito-identity list-identity-pools --max-results 50 | \
    jq -r ".IdentityPools[] | select(.IdentityPoolName == \"$IDPOOLNAME\") | .IdentityPoolId" 
}

cognito-identitypool-show () {
  IDPOOLNAME=$1
  IDPOOLID=$(cognito-identitypool-get-id $IDPOOLNAME)
  aws cognito-identity describe-identity-pool --identity-pool-id $IDPOOLID
}

cognito-identitypool-roles-show () {
  IDPOOLNAME=$1
  IDPOOLID=$(cognito-identitypool-get-id $IDPOOLNAME)
  aws cognito-identity get-identity-pool-roles --identity-pool-id $IDPOOLID
}


