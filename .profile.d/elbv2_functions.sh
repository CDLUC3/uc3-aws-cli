# Shell functions for quarying elbv2 LoadBalancers and TargetGroups



# EC2 Instance

ec2-instance-name() {
    ID=$1
    aws ec2 describe-instances --instance-ids $ID | \
	jq -r '.Reservations[].Instances[].Tags[] | select(.Key == "Name") | .Value'
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
