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
        #aws iam get-role-policy --role-name $1 --policy-name $POLICYNAME | jq -r
        aws --no-cli-pager --output yaml iam get-role-policy --role-name $1 --policy-name $POLICYNAME
    done
}

iam-role-list-attached-policy-arn() {
    aws iam list-attached-role-policies --role-name $1 | jq -r '.AttachedPolicies[].PolicyArn'
}

iam-role-show-attached-policies() {
    for POLICYARN in $(iam-role-list-attached-policy-arn $1); do
	iam-policy-show $POLICYARN
	echo
    done
}

iam-role-show-policies() {
    echo Inline Policies:
    iam-role-show-inline-policies $1
    echo
    echo Attached Policies:
    iam-role-show-attached-policies $1
}

iam-policy-list() {
    aws iam list-policies | jq -r '.Policies[].PolicyName' | sort
}

iam-policy-show-arn() {
    NAME=$1
    aws iam list-policies | jq -r ".Policies[] | select(.PolicyName == \"$NAME\") | .Arn"
}

iam-policy-show() {
    if $(echo $1 | egrep ^arn.* 2>&1 > /dev/null); then
	ARN=$1
    else
        ARN=$(iam-policy-show-arn $1)
    fi
    OUTPUT=$(aws iam get-policy --policy-arn $ARN)
    VERSION=$(echo $OUTPUT | jq -r '.Policy.DefaultVersionId')
    echo $OUTPUT | \
	    jq -r '.Policy | {"PolicyName": .PolicyName, "Description": .Description}'
    #aws iam get-policy-version --policy-arn $ARN --version-id $VERSION | jq -r '.PolicyVersion'
    aws --no-cli-pager --output yaml iam get-policy-version --policy-arn $ARN --version-id $VERSION
}

