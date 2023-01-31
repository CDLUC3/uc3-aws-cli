#!/usr/bin/env bash

ec2-vpc-list() {
  $AWSBIN ec2 describe-vpcs | yq -ry '.Vpcs[] | {"Id": .VpcId, "Cidr": .CidrBlock}' 
}

ec2-vpc-show() {
  $AWSBIN ec2 describe-vpcs  --vpc-id $1 | yq -ry .
}

ec2-sg-list() {
  $AWSBIN ec2 describe-security-groups | yq -r '.SecurityGroups[].GroupName'
}

ec2-sg-show() {
  SGNAME=$1
  $AWSBIN ec2 describe-security-groups --filters "Name=group-name,Values=$SGNAME" | yq -ry .
}

ec2-instance-list() {
    $AWSBIN ec2 describe-instances | \
	yq -r '.Reservations[].Instances[] | (select(.Tags != null) | .Tags[] | select(.Key == "Name") | .Value)'
}

ec2-instance-show() {
    NAME=$1
    $AWSBIN ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | yq -ry '.Reservations[].Instances[]'
}

ec2-instance-show-id() {
    NAME=$1
    $AWSBIN ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | \
	yq -r '.Reservations[].Instances[].InstanceId'
}

ec2-instance-show-name-from-id() {
    ID=$1
    #$AWSBIN ec2 describe-instances --instance-ids $ID | \
    aws ec2 describe-instances --instance-ids $ID | \
	yq -r '.Reservations[].Instances[].Tags[] | select(.Key == "Name") | .Value'
}

ec2-instance-show-tags() {
    helpmsg() {
        cat << EOF
Print AWS resource tags for the named EC2 instance.
If no instance name provided, get instance id from local ec2-metadata.

Args:
  -h: display help message
  <instance_name>: name of an EC2 instance in this AWS account

EOF
    }

    usage() {
        echo "Usage: ec2-instance-show-tags [-h | <instance_name>]"
    }

    if [ $# -gt 0 ]; then
        case $1 in
            '-h' )
	        helpmsg
	        usage
		;;
            * ) 
		NAME=$1
                INSTANCE_ID=$(ec2-instance-show-id $NAME)
                ;;
        esac
    elif $(which ec2-metadata > /dev/null 2>&1); then
        INSTANCE_ID=$(ec2-metadata -i| awk '{print $2}')
    else 
	echo "Cant determine instance id of localhost.  Is this a ec2 instance?"
	usage
	return
    fi

    EC2TAGS=$($AWSBIN --output json ec2 describe-tags --filter Name=resource-id,Values=${INSTANCE_ID})
    echo $EC2TAGS | jq -r '.Tags[] | [.Key, .Value] | join(": ")'
}
alias ec2-tags=ec2-instance-show-tags

ec2-instance-show-volumes() {
    NAME=$1
    $AWSBIN ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | \
	yq -r '.Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId'
}

ec2-snapshot-list() {
  $AWSBIN ec2 describe-snapshots --owner-id self | yq -ry .
}


ec2-snapshot-list-for-instance() {
  NAME=$1
  VOLUME_IDS=$(ec2-instance-show-volumes $NAME)
  for ID in $VOLUME_IDS; do
    echo "VolumeId: $ID"
    $AWSBIN ec2 describe-snapshots --filters Name=volume-id,Values=$ID | yq -ry .
    echo
  done
}
# aws ec2 describe-snapshots --filters Name=volume-id,Values=vol-05601fca3c2422c4d,vol-058f384c04bf7abe7

ec2-snapshots-create-for-instance() {
  NAME=$1
  INSTANCE_ID=$(ec2-instance-show-id $NAME)
  $AWSBIN ec2 create-snapshots --description $NAME --instance-specification InstanceId=$INSTANCE_ID 
}



# subnets
ec2-subnet-list() {
  $AWSBIN ec2 describe-subnets | yq -r '.Subnets[] | (select(.Tags != null) | .Tags[] | select(.Key == "Name") | .Value)'
}

ec2-subnet-show() {
 NAME=$1
 $AWSBIN ec2 describe-subnets  --filters "Name=tag:Name,Values=$NAME" | yq -ry .
}


# Notes

# aws ec2 describe-vpcs | jq -r ".Vpcs[].Tags[] | select(.Key == \"Name\") | ."

# aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "Id: \(.InstanceId)"'
# aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "InstanceId:\t\(.InstanceId)", (select(.Tags != null) | .Tags[] | select(.Key == "Name") | "Name:\t\t\(.Value)"), ""'
