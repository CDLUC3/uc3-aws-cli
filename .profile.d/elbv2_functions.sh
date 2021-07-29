# Shell functions for quarying elbv2 LoadBalancers and TargetGroups



# EC2 Instance

ec2-instance-name() {
    ID=$1
    aws ec2 describe-instances --instance-ids $ID | \
	jq -r '.Reservations[].Instances[].Tags[] | select(.Key == "Name") | .Value'
}

ec2-instance-id() {
    NAME=$1
    aws ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | \
        jq -r '.Reservations[].Instances[].InstanceId'
}


# ELBv2

elb-lb-list() {
    response=$(aws elbv2 describe-load-balancers)
    loadbalancers=$(echo $response | jq -r '.LoadBalancers[]')
    nextmarker=$(echo $response | jq -r '.NextMarker')
    while [ ! -n $nextmarker ]; do
        response=$(aws elbv2 describe-load-balancers --staring-token $nextmarker)
        loadbalancers=${loadbalancers}$(echo $response | jq -r '.LoadBalancers[]')
        nextmarker=$(echo $response | jq -r '.NextMarker')
    done
    echo $loadbalancers | jq -r '.LoadBalancerName' | sort
}

elb-lb-show() {
    aws elbv2 describe-load-balancers --names $1
}

elb-lb-show-arn() {
    aws elbv2 describe-load-balancers --names $1 | jq -r '.LoadBalancers[].LoadBalancerArn'
}

elb-tg-list() {
    NAME=$1
    if [ -n "$NAME" ]; then
        ARN=$(elb-lb-show-arn $NAME)
        aws elbv2 describe-target-groups --load-balancer-arn $arn | jq -r '.TargetGroups[].TargetGroupName'
    else
        #aws elbv2 describe-target-groups | jq -r '.TargetGroups[].TargetGroupName'
        response=$(aws elbv2 describe-target-groups)
        targetgroups=$(echo $response | jq -r '.TargetGroups[]')
        nextmarker=$(echo $response | jq -r '.NextMarker')
        while [ ! -n $nextmarker ]; do
            response=$(aws elbv2 describe-target-groups --staring-token $nextmarker)
            targetgroups=${targetgroups}$(echo $response | jq -r '.TargetGroups[]')
            nextmarker=$(echo $response | jq -r '.NextMarker')
        done
        echo $targetgroups | jq -r '.TargetGroupName' | sort
        fi
}
       
elb-tg-show() {
    NAME=$1
    aws elbv2 describe-target-groups | jq -r ".TargetGroups[] | select(.TargetGroupName == \"$NAME\")"
}

elb-tg-show-arn() {
    NAME=$1
    elb-tg-show $NAME | jq -r '.TargetGroupArn'
}

elb-tg-health() {
    NAME=$1
    ARN=$(elb-tg-show-arn $NAME)
    aws elbv2 describe-target-health --target-group-arn $ARN
}

elb-tg-hosts() {
    NAME=$1
    HEALTH=$(elb-tg-health $NAME)
    IDS=$(echo $HEALTH | jq -r '.TargetHealthDescriptions[].Target.Id')
    for id in $IDS; do
        hostname=$(ec2-instance-name $id)
        status=$(echo $HEALTH | jq -r ".TargetHealthDescriptions[] | select(.Target.Id == \"$id\") | .TargetHealth.State")
        echo -e "$hostname\t$id\t$status"
    done
}        

#aws elbv2 describe-target-group-attributes --target-group-arn $(elb-tg-show-arn uc3-mrtstore-pvt-prd-tg)
#aws elbv2 modify-target-group-attributes --target-group-arn $(elb-tg-show-arn uc3-dryad-dev-tg) --attributes Key=deregistration_delay.timeout_seconds,Value=30

elb-tg-show-attributes() {
    TG=$1
    aws elbv2 describe-target-group-attributes --target-group-arn $(elb-tg-show-arn $TG)
}

elb-tg-modify-attributes() {
    TG=$1
    KEY=$2
    VALUE=$3
    aws elbv2 modify-target-group-attributes --target-group-arn $(elb-tg-show-arn $TG) --attributes Key=$KEY,Value=$VALUE
}

# registering targets

elb-tg-register() {
    REGION=us-west-2
    TG=$1
    TARGET=$2
    aws elbv2 register-targets --region $REGION --target-group-arn $(elb-tg-show-arn $TG) --targets Id=$(ec2-instance-id $TARGET)
}

elb-tg-deregister() {
    REGION=us-west-2
    TG=$1
    TARGET=$2
    aws elbv2 deregister-targets --region $REGION --target-group-arn $(elb-tg-show-arn $TG) --targets Id=$(ec2-instance-id $TARGET)
}


# Argument is an ALB name
elb-listener-for-alb() {
    NAME=$1
    ARN=$(elb-lb-show-arn $NAME)
    aws elbv2 describe-listeners --load-balancer-arn $ARN
} 

elb-listener-for-alb-show-arn() {
    NAME=$1
    ARN=$(elb-lb-show-arn $NAME)
    aws elbv2 describe-listeners --load-balancer-arn $ARN | jq -r '.Listeners[].ListenerArn'
} 

elb-listener-rules-for-alb() {
    NAME=$1
    RULE_ARNS=$(elb-listener-for-alb-show-arn  $NAME)
    for arn in $RULE_ARNS; do
        echo "ListenerArn: $arn"
        aws elbv2 describe-rules --listener-arn $arn
    done
}
