#! /usr/bin/env bash


# Cloudformation query functions
#
cfn-stack-list() {
    $AWSBIN cloudformation describe-stacks | yq -r '.Stacks[].StackName'
}

cfn-stack-show() {
    $AWSBIN cloudformation describe-stacks --stack-name $1 | yq -ry '.Stacks[]'
    echo
    echo Resources:
    $AWSBIN cloudformation describe-stack-resources --stack-name $1 | yq -r '.StackResources[] | .LogicalResourceId, .ResourceType, ""'
}

cfn-stack-resources() {
    aws cloudformation describe-stack-resources --stack-name $1 | \
        yq -ry '.StackResources[]' | \
        egrep -v "StackId|StackName"
}

cfn-stack-template() {
    $AWSBIN cloudformation get-template --stack-name $1 --output json | \
        jq -r  '.TemplateBody'
}

cfn-stack-events() {
    $AWSBIN cloudformation describe-stack-events --stack-name $1 | \
        yq -ry '.StackEvents[]' | \
        egrep -v "StackId|EventId|StackName"
}

cfn-stack-drift() {
    $AWSBIN cloudformation detect-stack-drift --stack-name $1
    sleep 10
    $AWSBIN cloudformation describe-stack-resource-drifts --stack-name $1
}


# These will effect change
#
#cfn-stack-update() {
#    aws cloudformation update-stack --stack-name $1 --template-body file://$2
#}
#
#cfn-stack-cancel-update() {
#    aws cloudformation cancel-update-stack --stack-name $1
#}

cfn-stack-delete() {
   $AWSBIN cloudformation delete-stack --stack-name $1
}



