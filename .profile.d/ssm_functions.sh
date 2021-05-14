# Additional functions for SSM ParameterStore by Ashley
# See: https://github.com/ashleygould/ashley-aws-hacks

ssm-param-history() {
    aws ssm get-parameter-history --name $1
}

ssm-param-by-path() {
PARAMPATH=$1
    aws ssm get-parameters-by-path --path $PARAMPATH --recursive --region us-west-2 | jq -r '.Parameters' | jq -r '.[] | "\(.Name)\t\(.Value)"'
}

ssm-param-get() {
    aws ssm get-parameter --name $1 | jq -r '.Parameter.Value'
}

ssm-param-get-verbose() {
    aws ssm get-parameter --name $1
}

# for values which are URLs run `aws configure set cli_follow_urlparam false`
# to prevent aws-cli attepting resolve the value from the internet
ssm-param-put() {
    aws ssm put-parameter --name $1 --value $2 --type String
}

ssm-param-put-overwrite() {
    aws ssm put-parameter --name $1 --value $2 --type String --overwrite
}

ssm-param-delete() {
    aws ssm delete-parameter --name $1
}


