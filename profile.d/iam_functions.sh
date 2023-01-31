#y!/bin/bash
#
# these work for both aws-cli version 1 and 2

iam-user-list() {
    $AWSBIN iam list-users | jq -r '.Users[].UserName'
}

iam-user-show() {
        $AWSBIN iam get-user --user-name $1 | jq -r '.User'
    echo Groups:
    $AWSBIN iam list-groups-for-user --user-name $1 | jq -r '.Groups[].GroupName'
}

iam-group-list() {
    $AWSBIN iam list-groups | jq -r '.Groups[].GroupName'
}

iam-group-show() {
    $AWSBIN iam get-group --group-name $1 | grep -A 5 '"Group": {'
    $AWSBIN iam get-group --group-name $1 | grep UserName
}

iam-role-list() {
    $AWSBIN iam list-roles | jq -r '.Roles[].RoleName'
}

iam-role-show() {
    $AWSBIN iam get-role --role-name $1 | yq -ry '.Role'
    echo
    echo Inline Policies:
    $AWSBIN iam list-role-policies --role-name $1 | jq -r '.PolicyNames[]'
    echo
    echo Attached Policies:
    $AWSBIN iam list-attached-role-policies --role-name $1 | jq -r '.AttachedPolicies[].PolicyName'
    echo
}

iam-role-list-inline-policies() {
    $AWSBIN iam list-role-policies --role-name $1 | jq -r '.PolicyNames[]'
}

iam-role-show-inline-policies() {
    for POLICYNAME in $(iam-role-list-inline-policies $1); do
        $AWSBIN iam get-role-policy --role-name $1 --policy-name $POLICYNAME | yq -ry .
    done
}

iam-role-list-attached-policy-arn() {
    $AWSBIN iam list-attached-role-policies --role-name $1 | jq -r '.AttachedPolicies[].PolicyArn'
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
    $AWSBIN iam list-policies | jq -r '.Policies[].PolicyName' | sort
}

iam-policy-show-arn() {
    NAME=$1
    $AWSBIN iam list-policies | jq -r ".Policies[] | select(.PolicyName == \"$NAME\") | .Arn"
}

iam-policy-show() {
    if $(echo $1 | egrep ^arn.* 2>&1 > /dev/null); then
	ARN=$1
    else
        ARN=$(iam-policy-show-arn $1)
    fi
    OUTPUT=$($AWSBIN iam get-policy --policy-arn $ARN)
    VERSION=$(echo $OUTPUT | jq -r '.Policy.DefaultVersionId')
    echo $OUTPUT | yq -ry '.Policy | {"PolicyName": .PolicyName, "Description": .Description}'
    $AWSBIN iam get-policy-version --policy-arn $ARN --version-id $VERSION | yq -ry '.PolicyVersion'
}

