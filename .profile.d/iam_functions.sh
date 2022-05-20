#!/bin/bash

iam-user-list() {
    aws iam list-users | grep UserName
}

iam-user-show() {
    aws iam get-user --user-name $1
    aws iam list-groups-for-user --user-name $1 | grep GroupName
}

iam-group-list() {
    aws iam list-groups | grep GroupName
}

iam-group-show() {
    aws iam get-group --group-name $1 | grep -A 5 '"Group": {'
    aws iam get-group --group-name $1 | grep UserName
}

iam-role-list() {
    aws iam list-roles | jq -r '.Roles[].RoleName'
}

iam-role-show() {
    if aws-cli-is-v2; then
        aws --no-cli-pager iam get-role --role-name $1
        aws --no-cli-pager iam list-role-policies --role-name $1
    else
        aws iam get-role --role-name $1
        aws iam list-role-policies --role-name $1
    fi
}

iam-role-policy() {
    aws iam get-role-policy --role-name $1 --policy-name $2
}


