#!/usr/bin/env bash

ec2-vpc-list() {
  #aws ec2 describe-vpcs | jq -r '.Vpcs[] | .VpcId, .CidrBlock, .Tags, ""'
  aws ec2 describe-vpcs | jq -r '.Vpcs[] | {"Id": .VpcId, "Cidr": .CidrBlock}' | jq -r .
  #aws ec2 describe-vpcs | jq -r '.Vpcs' | jq -r '.[] | \"(.VpcId)\t\.(CidrBlock)\"'
}

ec2-sg-list() {
  aws ec2 describe-security-groups | jq -r '.SecurityGroups[] | .GroupName, .Description, .GroupId, .VpcId, ""'
}

ec2-instance-list() {
    aws ec2 describe-instances | \
	jq -r '.Reservations[].Instances[] | (select(.Tags != null) | .Tags[] | select(.Key == "Name") | .Value)'

	#jq -r '.Reservations[].Instances[] | "Id: \(.InstanceId)"'
	#jq -r '.Reservations[].Instances[] | "InstanceId:\t\(.InstanceId)", (select(.Tags != null) | .Tags[] | select(.Key == "Name") | "Name:\t\t\(.Value)"), ""'

}

ec2-instance-show() {
    NAME=$1
    aws --no-cli-pager --output yaml ec2 describe-instances --filters "Name=tag:Name,Values=$NAME"
}

ec2-instance-show-id() {
    NAME=$1
    aws ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | \
	jq -r '.Reservations[].Instances[].InstanceId'
}

ec2-instance-show-volumes() {
    NAME=$1
    aws ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | \
	jq -r '.Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId'
}

ec2-snapshot-list() {
  aws --no-cli-pager --output yaml ec2 describe-snapshots --owner-id self
}


ec2-snapshot-list-for-instance() {
  NAME=$1
  VOLUME_IDS=$(ec2-instance-show-volumes $NAME)
  for ID in $VOLUME_IDS; do
    echo "VolumeId: $ID"
    aws --no-cli-pager --output yaml ec2 describe-snapshots --filters Name=volume-id,Values=$ID
  done
}
# aws ec2 describe-snapshots --filters Name=volume-id,Values=vol-05601fca3c2422c4d,vol-058f384c04bf7abe7

ec2-snapshots-create-for-instance() {
  NAME=$1
  INSTANCE_ID=$(ec2-instance-show-id $NAME)
  aws --no-cli-pager ec2 create-snapshots --description $NAME --instance-specification InstanceId=$INSTANCE_ID

}



# subnets
ec2-subnet-list() {
  aws ec2 describe-subnets | jq -r '.Subnets[] | (select(.Tags != null) | .Tags[] | select(.Key == "Name") | .Value)'
}

ec2-subnet-show() {
 NAME=$1
 aws --no-cli-pager --output yaml ec2 describe-subnets  --filters "Name=tag:Name,Values=$NAME"
}


# Notes

# aws ec2 describe-vpcs | jq -r ".Vpcs[].Tags[] | select(.Key == \"Name\") | ."

