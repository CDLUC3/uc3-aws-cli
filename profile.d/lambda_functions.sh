#! /usr/bin/env bash

# Lambda query functions

lambda-function-list() {
    $AWSBIN lambda list-functions | yq -r .Functions[].FunctionName
}

lambda-function-show() {
    $AWSBIN lambda get-function --function-name $1 | yq -ry .
}

lambda-function-show-policy() {
    NAME=$1
    $AWSBIN lambda get-policy --function-name $NAME > /dev/null 2>&1 && \
    $AWSBIN lambda get-policy --function-name $NAME --output json | jq -r .Policy | json2yaml.py
}

lambda-function-show-config() {
    $AWSBIN lambda get-function-configuration --function-name $1 | yq -ry . 
}

lambda-function-download-code() {
    NAME=$1
    TMPDIR=$(mktemp -d)
    echo "Downloading to $TMPDIR/function_code.zip"
    aws lambda get-function --function-name $NAME --query 'Code.Location'  | xargs wget -q -O $TMPDIR/function_code.zip
    echo "Unzipping into $TMPDIR"
    unzip -q -d $TMPDIR $TMPDIR/function_code.zip
    ls -l $TMPDIR
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

