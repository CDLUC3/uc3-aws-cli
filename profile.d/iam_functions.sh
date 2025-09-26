#!/bin/bash
#
# these work for both aws-cli version 1 and 2

iam-user-list() {
    $AWSBIN iam list-users | yq -r '.Users[].UserName'
}

iam-user-show() {
    $AWSBIN iam get-user --user-name $1 | yq -ry '.User'
    echo Groups:
    $AWSBIN iam list-groups-for-user --user-name $1 | yq -r '.Groups[].GroupName'
}

iam-group-list() {
    $AWSBIN iam list-groups | yq -r '.Groups[].GroupName'
}

iam-group-show() {
    $AWSBIN iam get-group --group-name $1
}


# Role Functions

iam-role-list() {
    $AWSBIN iam list-roles | yq -r '.Roles[].RoleName'
}

iam-role-show() {
    $AWSBIN iam get-role --role-name $1 | yq -ry '.Role'
    echo
    echo Inline Policies:
    $AWSBIN iam list-role-policies --role-name $1 | yq -r '.PolicyNames[]'
    echo
    echo Attached Policies:
    $AWSBIN iam list-attached-role-policies --role-name $1 | yq -r '.AttachedPolicies[].PolicyName'
    echo
}

iam-role-list-inline-policies() {
    $AWSBIN iam list-role-policies --role-name $1 | yq -r '.PolicyNames[]'
}

iam-role-show-inline-policies() {
    for POLICYNAME in $(iam-role-list-inline-policies $1); do
        $AWSBIN iam get-role-policy --role-name $1 --policy-name $POLICYNAME | yq -ry .
    done
}

iam-role-list-attached-policy-arn() {
    $AWSBIN iam list-attached-role-policies --role-name $1 | yq -r '.AttachedPolicies[].PolicyArn'
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

iam-role-delete() {
    ROLE_NAME=$1
    $AWSBIN iam delete-role --role-name $ROLE_NAME
}


# Policy Functions

iam-policy-list() {
    $AWSBIN iam list-policies | yq -r '.Policies[].PolicyName' | sort
}

iam-policy-show-arn() {
    NAME=$1
    $AWSBIN iam list-policies | yq -r ".Policies[] | select(.PolicyName == \"$NAME\") | .Arn"
}

iam-policy-show() {
    if $(echo $1 | egrep ^arn.* 2>&1 > /dev/null); then
	ARN=$1
    else
        ARN=$(iam-policy-show-arn $1)
    fi
    OUTPUT=$($AWSBIN iam get-policy --policy-arn $ARN)
    VERSION=$(echo "$OUTPUT" | yq -r '.Policy.DefaultVersionId')
    echo "$OUTPUT" | yq -ry '.Policy | {"PolicyName": .PolicyName, "Description": .Description}'
    $AWSBIN iam get-policy-version --policy-arn $ARN --version-id $VERSION | yq -ry '.PolicyVersion'
}

iam-policy-detach() {
    # Currently only detaches from roles
    if $(echo $1 | egrep ^arn.* 2>&1 > /dev/null); then
        ARN=$1
    else
        ARN=$(iam-policy-show-arn $1)
    fi
    ROLES=$(aws iam list-entities-for-policy --policy-arn $ARN | jq -r '.PolicyRoles[].RoleName')
    for role_name in $ROLES; do
    echo $role_name
        $AWSBIN iam detach-role-policy --role-name $role_name --policy-arn $ARN
    done
}

iam-policy-delete() {
    if $(echo $1 | egrep ^arn.* 2>&1 > /dev/null); then
        ARN=$1
    else
        ARN=$(iam-policy-show-arn $1)
    fi
    POLICY_VERSIONS=$($AWSBIN iam list-policy-versions --policy-arn $ARN | yq -r '.Versions[].VersionId')
    #echo "$POLICY_VERSIONS"
    for version in $POLICY_VERSIONS; do
	echo $version
	$AWSBIN iam delete-policy-version --policy-arn $ARN --version-id $version
    done
    $AWSBIN iam delete-policy --policy-arn $ARN
}


