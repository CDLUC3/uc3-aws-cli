#!/usr/bin/env bash

ec2-vpc-list() {
  $AWSBIN ec2 describe-vpcs | yq -ry '.Vpcs[] | {"Id": .VpcId, "Cidr": .CidrBlock}' 
}

ec2-vpc-show() {
  $AWSBIN ec2 describe-vpcs  --vpc-id $1
}

ec2-sg-list() {
  $AWSBIN ec2 describe-security-groups | yq -r '.SecurityGroups[].GroupName'
}

ec2-sg-show() {
  SGNAME=$1
  $AWSBIN ec2 describe-security-groups --filters "Name=group-name,Values=$SGNAME"
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

ec2-instance-show-tags() {
    NAME=$1
    $AWSBIN ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | \
	yq -ry '.Reservations[].Instances[].Tags[]'
}

ec2-instance-show-volumes() {
    NAME=$1
    $AWSBIN ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | \
	yq -r '.Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId'
}

ec2-snapshot-list() {
  $AWSBIN ec2 describe-snapshots --owner-id self
}


ec2-snapshot-list-for-instance() {
  NAME=$1
  VOLUME_IDS=$(ec2-instance-show-volumes $NAME)
  for ID in $VOLUME_IDS; do
    echo "VolumeId: $ID"
    $AWSBIN ec2 describe-snapshots --filters Name=volume-id,Values=$ID
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
 $AWSBIN ec2 describe-subnets  --filters "Name=tag:Name,Values=$NAME"
}


# Notes

# aws ec2 describe-vpcs | jq -r ".Vpcs[].Tags[] | select(.Key == \"Name\") | ."

# aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "Id: \(.InstanceId)"'
# aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "InstanceId:\t\(.InstanceId)", (select(.Tags != null) | .Tags[] | select(.Key == "Name") | "Name:\t\t\(.Value)"), ""'
