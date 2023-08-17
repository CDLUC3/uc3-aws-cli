#!/bin/bash
#

aws-version() {
    aws --version 2>&1 | awk '{print $1}' | awk -F / '{print $2}'
}

aws-cli-is-v2() {
    aws --version 2>&1 | egrep "^aws-cli/2.*?" >/dev/null
}

if $(aws-cli-is-v2); then
    AWSBIN="aws --no-cli-pager --output yaml"
else
    AWSBIN=aws
fi
export AWSBIN


aws-whoami() {
  if [ $# -gt 0 ]; then
    case $1 in
      '-h' ) echo "Print output of 'aws sts get-caller-identity";;
      * ) return;;
    esac
  else
    $AWSBIN sts get-caller-identity
  fi
}

aws-account-id() {
  $AWSBIN sts get-caller-identity | yq -r '.Account'
}

aws-region ()
{
  if [ $# -gt 0 ]; then
    case $1 in
      '-h' ) echo "Set or display value of shell environment var AWS_DEFAULT_REGION";;
      * ) export AWS_DEFAULT_REGION=$1;;
    esac
  else
      echo $AWS_DEFAULT_REGION;
  fi
}

aws-profile() {
  usage() {
    cat << EOF
Set or display value of shell environment var AWS_PROFILE.
If no args, echo the current value of AWS_PROFILE.

Usage: aws-profile [-h | -u | <profile_name>]

Args:
  -h: display help message
  -u: unset env var AWS_PROFILE
  <profile_name>: set env var AWS_PROFILE to "profile_name"

EOF
  }

  if [ $# -gt 0 ]; then
    case $1 in
      '-h' ) usage;;
      '-u' ) unset AWS_PROFILE;;
      * ) export AWS_PROFILE=$1;;
    esac
  fi
  echo $AWS_PROFILE
}

