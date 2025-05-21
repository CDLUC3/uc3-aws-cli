#! /usr/bin/env bash

# Lambda query functions

lambda-function-list() {
    $AWSBIN lambda list-functions | yq -r .Functions[].FunctionName
}

lambda-function-show() {
    $AWSBIN lambda get-function --function-name $1 | yq -ry .
}

lambda-function-show-policy() {
    $AWSBIN lambda get-policy --function-name $1 --output text | yq -ry . 2>/dev/null
}

lambda-function-show-config() {
    $AWSBIN lambda get-function-configuration --function-name $1 | yq -ry . 
}


#lambda-function-update() {
#    bucket=$1
#    key=$2
#    name=$3
#    $AWSBIN lambda update-function-code --s3-bucket $bucket --s3-key $key --function-name $name
#}
#
#
#lambda-function-delete() {
#    $AWSBIN lambda delete-function --function-name $1
#}

