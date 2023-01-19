# Shell functions for quarying elbv2 LoadBalancers and TargetGroups



# ELBv2 ALBs

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

elb-lb-list-arn() {
    response=$(aws elbv2 describe-load-balancers)
    loadbalancers=$(echo $response | jq -r '.LoadBalancers[]')
    nextmarker=$(echo $response | jq -r '.NextMarker')
    while [ ! -n $nextmarker ]; do
        response=$(aws elbv2 describe-load-balancers --staring-token $nextmarker)
        loadbalancers=${loadbalancers}$(echo $response | jq -r '.LoadBalancers[]')
        nextmarker=$(echo $response | jq -r '.NextMarker')
    done
    echo $loadbalancers | jq -r '.LoadBalancerArn' | sort
}

elb-lb-show-arn() {
    aws elbv2 describe-load-balancers --names $1 | jq -r '.LoadBalancers[].LoadBalancerArn'
}

elb-lb-show-tags() {
    REGION=us-west-2
    LB=$1
    aws elbv2 describe-tags --resource-arns $(elb-lb-show-arn $LB) | jq -r '.TagDescriptions[].Tags[]'
}

elb-lb-show-attributes() {
    REGION=us-west-2
    LB=$1
    aws elbv2 describe-load-balancer-attributes --load-balancer-arn $(elb-lb-show-arn $LB) | jq -r '.Attributes[]'
}

# Return ALB and TargetGroup names for given ec2 instance name.
# If no instance name provided, get instance id from local ec2-metadata.
#
elb-lb-list-for-instance() {
    NAME=$1
    if [ -n "$NAME" ]; then
        eval $(ec2-instance-show-tags $NAME)
    else
        eval $(ec2-metadata-show-tags)
    fi

    for lb_arn in $(elb-lb-list-arn); do
        lb_tags=$($AWSBIN --output json elbv2 describe-tags --resource-arns $lb_arn | jq -r '.TagDescriptions[]')
        lb_program=$(echo ${lb_tags} | jq -r '.Tags[] | select(.Key=="Program") | .Value')
        lb_service=$(echo ${lb_tags} | jq -r '.Tags[] | select(.Key=="Service") | .Value')
        lb_subservice=$(echo ${lb_tags} | jq -r '.Tags[] | select(.Key=="Subservice") | .Value')
        lb_environment=$(echo ${lb_tags} | jq -r '.Tags[] | select(.Key=="Environment") | .Value')
        if [ "$Program" == "$lb_program" ] && [ "$Service" == "$lb_service" ] && [ "$Subservice" == "$lb_subservice" ]  && [ "$Environment" == "$lb_environment" ] ; then
            $AWSBIN --output json elbv2 describe-load-balancers  --load-balancer-arns $lb_arn | jq -r '.LoadBalancers[].LoadBalancerName'
            aws elbv2 describe-target-groups  --load-balancer-arn $lb_arn | jq -r '.TargetGroups[].TargetGroupName'
            break
        fi
    done
}


# ALB TargetGroups

elb-tg-list() {
    NAME=$1
    if [ -n "$NAME" ]; then
        ARN=$(elb-lb-show-arn $NAME)
        aws elbv2 describe-target-groups --load-balancer-arn $arn | jq -r '.TargetGroups[].TargetGroupName'
    else
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

elb-tg-list-arn() {
    response=$(aws elbv2 describe-target-groups)
    targetgroups=$(echo $response | jq -r '.TargetGroups[]')
    nextmarker=$(echo $response | jq -r '.NextMarker')
    while [ ! -n $nextmarker ]; do
        response=$(aws elbv2 describe-target-groups --staring-token $nextmarker)
        targetgroups=${targetgroups}$(echo $response | jq -r '.TargetGroups[]')
        nextmarker=$(echo $response | jq -r '.NextMarker')
    done
    echo $targetgroups | jq -r '.TargetGroupArn' | sort
}
       
elb-tg-show() {
    NAME=$1
    aws elbv2 describe-target-groups --names $NAME | jq -r ".TargetGroups[]"
}

elb-tg-show-arn() {
    NAME=$1
    elb-tg-show $NAME | jq -r '.TargetGroupArn'
}

elb-tg-show-tags() {
    REGION=us-west-2
    TG=$1
    aws elbv2 describe-tags --resource-arns $(elb-tg-show-arn $TG) | jq -r '.TagDescriptions[].Tags[]'
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

# Registering targets

elb-tg-register() {
    TG=$1
    TARGET=$2
    aws elbv2 register-targets --region $REGION --target-group-arn $(elb-tg-show-arn $TG) --targets Id=$(ec2-instance-show-id $TARGET)
}

elb-tg-deregister() {
    TG=$1
    TARGET=$2
    aws elbv2 deregister-targets --region $REGION --target-group-arn $(elb-tg-show-arn $TG) --targets Id=$(ec2-instance-show-id $TARGET)
}


# ALB Listeners

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


