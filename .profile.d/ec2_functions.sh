#!/usr/bin/env bash

ec2-vpc-list() {
  #aws ec2 describe-vpcs | jq -r '.Vpcs[] | .VpcId, .CidrBlock, .Tags, ""'
  aws ec2 describe-vpcs | jq -r '.Vpcs[] | {"Id": .VpcId, "Cidr": .CidrBlock}' | jq -r .
  #aws ec2 describe-vpcs | jq -r '.Vpcs' | jq -r '.[] | \"(.VpcId)\t\.(CidrBlock)\"'
}

ec2-sg-list() {
  aws ec2 describe-security-groups | jq -r '.SecurityGroups[] | .GroupName, .Description, .GroupId, .VpcId, ""'
}








# Notes

# aws ec2 describe-vpcs | jq -r ".Vpcs[].Tags[] | select(.Key == \"Name\") | ."

