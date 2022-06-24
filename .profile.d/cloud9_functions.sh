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
