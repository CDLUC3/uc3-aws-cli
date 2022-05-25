#!/bin/bash

aws-whoami() {
  if [ $# -gt 0 ]; then
    case $1 in
      '-h' ) echo "Print output of 'aws sts get-caller-identity";;
      * ) return;;
    esac
  else
    aws sts get-caller-identity
  fi
}


aws-region ()
{
  if [ $# -gt 0 ]; then
    case $1 in
      '-h' ) echo "Set or display value of shell environment var AWS_DEFAULT_PROFILE";;
      * ) export AWS_DEFAULT_REGION=$region;;
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

aws-cli-is-v2() {
    aws --version | egrep "^aws-cli\/2.*?" 2>&1 >/dev/null
}

aws-version() {
    aws --version | awk '{print $1}' | awk -F / '{print $2}'
}
    