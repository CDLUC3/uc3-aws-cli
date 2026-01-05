#! /usr/bin/env bash


# Cloudformation query functions
#
cfn-stack-list() {
    $AWSBIN cloudformation describe-stacks | yq -r '.Stacks[].StackName'
}

cfn-stack-grep() {
    SUBSTRING=$1
    $AWSBIN cloudformation describe-stacks | yq -r '.Stacks[].StackName' | grep $SUBSTRING
}

cfn-stack-show() {
    $AWSBIN cloudformation describe-stacks --stack-name $1 | yq -ry '.Stacks[]'
    echo
    echo Resources:
    $AWSBIN cloudformation describe-stack-resources --stack-name $1 | yq -r '.StackResources[] | .LogicalResourceId, .ResourceType, ""'
}

cfn-stack-outputs() {
    $AWSBIN cloudformation describe-stacks --stack-name $1 | yq -ry '.Stacks[].Outputs'
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

cfn-changeset-list() {
    STACK_NAME=$1
    $AWSBIN cloudformation list-change-sets --stack-name $STACK_NAME
}

cfn-changeset-show() {
    STACK_NAME=$1
    CHANGESET_NAME=$2
    $AWSBIN cloudformation describe-change-set --stack-name $STACK_NAME --change-set-name $CHANGESET_NAME
}

cfn-changeset-execute() {
    STACK_NAME=$1
    CHANGESET_NAME=$2
    $AWSBIN cloudformation execute-change-set --stack-name $STACK_NAME --change-set-name $CHANGESET_NAME
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

cfn-stack-delete-force() {
   $AWSBIN cloudformation delete-stack --stack-name $1 --deletion-mode FORCE_DELETE_STACK
}


cfn-stack-create() {
   $AWSBIN cloudformation create-stack --stack-name $1 --template-body file://$2 --capabilities CAPABILITY_NAMED_IAM
}

# > aws cloudformation continue-update-rollback --stack-name dmp-tool-dev-ecs-apollo --resources-to-skip EcsService
cfn-stack-rollback() {
   $AWSBIN cloudformation continue-update-rollback --stack-name $1
}


