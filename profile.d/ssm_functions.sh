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
    aws ssm get-parameter --name $1 --with-decryption | jq -r '.Parameter.Value'
}

ssm-param-get-verbose() {
    aws ssm get-parameter --name $1
}

# for values which are URLs run `aws configure set cli_follow_urlparam false`
# to prevent aws-cli attempting resolve the value from the internet
ssm-param-put() {
    aws ssm put-parameter --name $1 --value $2 --type String
}

ssm-param-put-encrypt() {
    aws ssm put-parameter --name $1 --value $2 --type SecureString
}

ssm-param-put-overwrite() {
    aws ssm put-parameter --name $1 --value $2 --type String --overwrite
}

ssm-param-delete() {
    aws ssm delete-parameter --name $1
}

# Build SSM search path from local ec2 instance tags
ssm-path-from-tags() {
    INSTANCE_ID=$(ec2-metadata -i| awk {'print $2}')
    EC2TAGS=$(aws ec2 describe-tags --filter Name=resource-id,Values=${INSTANCE_ID})
    tag_prog=$(echo ${EC2TAGS} | jq -r '.Tags[] | select(.Key=="Program") | .Value')
    tag_srvc=$(echo ${EC2TAGS} | jq -r '.Tags[] | select(.Key=="Service") | .Value')
    tag_subsrvc=$(echo ${EC2TAGS} | jq -r '.Tags[] | select(.Key=="Subservice") | .Value')
    tag_env=$(echo ${EC2TAGS} | jq -r '.Tags[] | select(.Key=="Environment") | .Value')
    SSM_PATH="/$tag_prog/$tag_srvc/$tag_subsrvc/$tag_env"
    echo $SSM_PATH
}
