#!/usr/bin/env bash


cloud9-env-list() {
    aws cloud9 describe-environments --cli-input-json "$(aws --no-cli-pager cloud9 list-environments)" | jq -r '.environments[].name'
}

cloud9-env-show() {
    ENV_NAME=$1
    aws cloud9 describe-environments --cli-input-json "$(aws --no-cli-pager cloud9 list-environments)" | jq -r ".environments[] | select(.name == \"$ENV_NAME\") | ."
}

cloud9-env-show-id() {
    ENV_NAME=$1
    aws cloud9 describe-environments --cli-input-json "$(aws --no-cli-pager cloud9 list-environments)" | jq -r ".environments[] | select(.name == \"$ENV_NAME\") | .id"
}

cloud9-env-show-memberships() {
    ENV_NAME=$1
    aws --no-cli-pager --output yaml cloud9 describe-environment-memberships --environment-id $(cloud9-env-show-id $ENV_NAME)
}

cloud9-env-add-membership() {
    ENV_NAME=$1
    USER_ARN=$2
    PERMS=$3
    aws --no-cli-pager --output yaml cloud9 create-environment-membership --environment-id $(cloud9-env-show-id $ENV_NAME) --user-arn $USER_ARN --permissions $PERMS
}

cloud9-env-remove-membership() {
    ENV_NAME=$1
    USER_ARN=$2
    aws --no-cli-pager --output yaml cloud9 delete-environment-membership --environment-id $(cloud9-env-show-id $ENV_NAME) --user-arn $USER_ARN
}

cloud9-env-delete() {
    ENV_NAME=$1
    aws cloud9 delete-environment --environment-id $(cloud9-env-show-id $ENV_NAME)
}


# NOTES
#
# agould@localhost:~> aws --no-cli-pager --output yaml cloud9 list-environments
# environmentIds:
# - 2da50bec5f744176b0481c481655cf4c
# - caafd9c3d0a3489d8ada9b4b55aa5f7a
# - b3dc9feefbea4c028c10b4b5be0be167
# agould@localhost:~> aws cloud9 describe-environments --environment-id 2da50bec5f744176b0481c481655cf4c
# 
# 
# aws --no-cli-pager cloud9 list-environments
# 
# 
# aws cloud9 describe-environments --cli-input-json "$(aws --no-cli-pager cloud9 list-environments)"
# 
# aws cloud9 describe-environments --cli-input-json "$(aws --no-cli-pager cloud9 list-environments)" | jq -r '.environments[].name'
# 
# 
# aws cloud9 describe-environments --cli-input-json "$(aws --no-cli-pager cloud9 list-environments)" | jq -r ".environments[] | select(.name == \"AshleyFirstPass\") | ."

# agould@localhost:~/.aws> aws --no-cli-pager --output yaml cloud9 describe-environment-memberships --environment-id 141e58ccdbcb478ab34c00e34dafbfd8
# memberships:
# - environmentId: 141e58ccdbcb478ab34c00e34dafbfd8
#   lastAccess: '2022-07-06T09:19:23-07:00'
#   permissions: owner
#   userArn: arn:aws:sts::671846987296:assumed-role/AWSReservedSSO_uc3-dev-intern_1b6c0210f99781dd/agould
#   userId: AROAZY3JTOYQFDTW6EBKL:agould
# - environmentId: 141e58ccdbcb478ab34c00e34dafbfd8
#   permissions: read-write
#   userArn: arn:aws:sts::671846987296:assumed-role/AWSReservedSSO_uc3-dev-intern_1b6c0210f99781dd/ediakone
#   userId: AROAZY3JTOYQFDTW6EBKL:ediakone

