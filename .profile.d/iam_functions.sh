#!/bin/bash
#
# these work for both aws-cli version 1 and 2

iam-user-list() {
    aws iam list-users | jq -r '.Users[].UserName'
}

iam-user-show() {
        aws iam get-user --user-name $1 | jq -r '.User'
    echo Groups:
    aws iam list-groups-for-user --user-name $1 | jq -r '.Groups[].GroupName'
}

iam-group-list() {
    aws iam list-groups | jq -r '.Groups[].GroupName'
}

iam-group-show() {
    aws iam get-group --group-name $1 | grep -A 5 '"Group": {'
    aws iam get-group --group-name $1 | grep UserName
}

iam-role-list() {
    aws iam list-roles | jq -r '.Roles[].RoleName'
}

iam-role-show() {
    aws iam get-role --role-name $1 | jq -r '.Role'
    echo
    echo Inline Policies:
    aws iam list-role-policies --role-name $1 | jq -r '.PolicyNames[]'
    echo
    echo Attached Policies:
    aws iam list-attached-role-policies --role-name $1 | jq -r '.AttachedPolicies[].PolicyName'
    echo
}

iam-role-list-inline-policies() {
    aws iam list-role-policies --role-name $1 | jq -r '.PolicyNames[]'
}

iam-role-show-inline-policies() {
    for POLICYNAME in $(iam-role-list-inline-policies $1); do
        aws iam get-role-policy --role-name $1 --policy-name $POLICYNAME | jq -r
    done
}

iam-role-list-attached-policy-arn() {
    aws iam list-attached-role-policies --role-name $1 | jq -r '.AttachedPolicies[].PolicyArn'
}

iam-role-show-attached-policies() {
    for POLICYARN in $(iam-role-list-attached-policy-arn $1); do
        aws iam get-policy --policy-arn $POLICYARN | jq -r '.Policy'
    done
}

iam-role-show-policies() {
    echo Inline Policies:
    iam-role-show-inline-policies $1
    echo
    echo Attached Policies:
    iam-role-show-attached-policies $1
}

