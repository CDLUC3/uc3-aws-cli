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


lambda-function-invoke () {

    FUNCTION_NAME=$1
    PAYLOAD_FILE=$2
    RESPONSE_FILE=$(mktemp --suffix=.json)
    echo $RESPONSE_FILE

    $AWSBIN lambda invoke  --function-name $FUNCTION_NAME \
      --invocation-type RequestResponse \
      --cli-binary-format raw-in-base64-out \
      --payload file://$PAYLOAD_FILE \
      $RESPONSE_FILE
    rm $RESPONSE_FILE

}

#agould@linux:~/tmp> cat lambda_payload.json
#{
#  "cluster": "ezid-common-dev-ecscluster",
#  "service_name": "ezid-n2t-dev-web-ecs",
#  "ssm_base_path": "/uc3/ezid/autodeploy",
#  "environment": "dev"
#}
#agould@linux:~/tmp> lambda-function-invoke ezid-n2t-dev-web-autodeploy-EcsServiceRestart lambda_payload.json 
#/tmp/tmp.IWTwQkNA3C.json
#ExecutedVersion: $LATEST
#StatusCode: 200




