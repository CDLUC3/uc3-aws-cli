#! /usr/bin/env bash


# Cloudformation query functions
#
cfn-stack-list() {
    aws cloudformation describe-stacks | jq -r '.Stacks[].StackName'
}

cfn-stack-show() {
    aws cloudformation describe-stacks --stack-name $1 | jq -r '.Stacks[]'
    echo
    echo Resources:
    aws cloudformation describe-stack-resources --stack-name $1 | jq -r '.StackResources[] | .LogicalResourceId, .ResourceType, ""'
}

cfn-stack-resources() {
    aws cloudformation describe-stack-resources --stack-name $1 | \
	    egrep -v "StackId|StackName" | \
            jq -r '.StackResources[]'
}

cfn-stack-template() {
    # if yq is installed:
    if $(which yq 2>&1 > /dev/null); then
        aws cloudformation get-template --stack-name $1 --output json | yq -yr  '.TemplateBody'
    else
        aws cloudformation get-template --stack-name $1 --output json | jq -r  '.TemplateBody'
    fi
}

cfn-stack-events() {
    aws cloudformation describe-stack-events --stack-name $1 | \
	    egrep -v "StackId|EventId|StackName" | \
	    jq -r '.StackEvents[]'
}

cfn-stack-drift() {
    aws cloudformation detect-stack-drift --stack-name $1
    sleep 10
    aws cloudformation describe-stack-resource-drifts --stack-name $1
}


# These will effect change
#
cfn-stack-cancel-update() {
    aws cloudformation cancel-update-stack --stack-name $1
}

cfn-stack-delete() {
   aws cloudformation delete-stack --stack-name $1
}



