#! /usr/bin/env bash

# Lambda query functions

lambda-function-list() {
    aws lambda list-functions | jq -r .Functions[].FunctionName
}

lambda-function-show() {
    aws lambda get-function --function-name $1
}

lambda-function-show-policy() {
    aws lambda get-policy --function-name $1 --output text | jq -r . 2>/dev/null
}

lambda-function-show-config() {
    aws lambda get-function-configuration --function-name $1
}


#lambda-function-update() {
#    bucket=$1
#    key=$2
#    name=$3
#    aws lambda update-function-code --s3-bucket $bucket --s3-key $key --function-name $name
#}
#
#
#lambda-function-delete() {
#    aws lambda delete-function --function-name $1
#}

