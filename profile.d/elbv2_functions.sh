# Shell functions for quarying elbv2 LoadBalancers and TargetGroups

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
    $AWSBIN elbv2 describe-load-balancers --names $1
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
    LB=$1
    aws elbv2 describe-tags --resource-arns $(elb-lb-show-arn $LB) | \
        jq -r '.TagDescriptions[].Tags[] | [.Key, .Value] | join(":\t")'
}

# aws elbv2 modify-load-balancer-attributes --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:451826914157:loadbalancer/app/uc3-dmptool-dev-alb/dc465ab590575ee1 --attributes Key=access_logs.s3.prefix,Value=dev
#
elb-lb-show-attributes() {
    LB=$1
    aws elbv2 describe-load-balancer-attributes --load-balancer-arn $(elb-lb-show-arn $LB) | \
        jq -r '.Attributes[] | [.Key, .Value] | join(": ")'
}

elb-lb-modify-attributes() {
    LB=$1
    KEY=$2
    VALUE=$3
    aws elbv2 modify-load-balancer-attributes --load-balancer-arn $(elb-lb-show-arn $LB) --attributes Key=$KEY,Value=$VALUE
}





## Return ALB and TargetGroup names for given ec2 instance name.
## If no instance name provided, get instance id from local ec2-metadata.
##
#elb-lb-list-for-instance() {
#    NAME=$1
#    Program=$(ec2-instance-show-tags $NAME | yq -r .Program)
#    Service=$(ec2-instance-show-tags $NAME | yq -r .Service)
#    Subservice=$(ec2-instance-show-tags $NAME | yq -r .Subservice)
#    Environment=$(ec2-instance-show-tags $NAME | yq -r .Environment)
#
#    for lb_arn in $(elb-lb-list-arn); do
#        lb_tags=$(aws elbv2 describe-tags --resource-arns $lb_arn | jq -r '.TagDescriptions[]')
#        lb_program=$(echo ${lb_tags} | jq -r '.Tags[] | select(.Key=="Program") | .Value')
#        lb_service=$(echo ${lb_tags} | jq -r '.Tags[] | select(.Key=="Service") | .Value')
#        lb_subservice=$(echo ${lb_tags} | jq -r '.Tags[] | select(.Key=="Subservice") | .Value')
#        lb_environment=$(echo ${lb_tags} | jq -r '.Tags[] | select(.Key=="Environment") | .Value')
#        if [ "$Program" == "$lb_program" ] && [ "$Service" == "$lb_service" ] && [ "$Subservice" == "$lb_subservice" ]  && [ "$Environment" == "$lb_environment" ] ; then
#            aws elbv2 describe-load-balancers  --load-balancer-arns $lb_arn | jq -r '.LoadBalancers[].LoadBalancerName'
#            aws elbv2 describe-target-groups  --load-balancer-arn $lb_arn | jq -r '.TargetGroups[].TargetGroupName'
#            break
#        fi
#    done
#}


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
    $AWSBIN elbv2 describe-target-groups --names $NAME | yq -ry ".TargetGroups[]"
}

elb-tg-show-arn() {
    NAME=$1
    elb-tg-show $NAME | yq -r '.TargetGroupArn'
}

elb-tg-show-targettype() {
    NAME=$1
    elb-tg-show $NAME | yq -r '.TargetType'
}

elb-tg-show-tags() {
    TG=$1
    aws elbv2 describe-tags --resource-arns $(elb-tg-show-arn $TG) | \
        jq -r '.TagDescriptions[].Tags[] | [.Key, .Value] | join(":\t")'
}

elb-tg-health() {
    NAME=$1
    ARN=$(elb-tg-show-arn $NAME)
    $AWSBIN elbv2 describe-target-health --target-group-arn $ARN
}

elb-tg-hosts() {
    NAME=$1
    TARGETTYPE=$(elb-tg-show-targettype $NAME)
    HEALTH=$(elb-tg-health $NAME)
    IDS=$(echo "$HEALTH" | yq -r '.TargetHealthDescriptions[].Target.Id')
    for id in $IDS; do
        status=$(echo "$HEALTH" | yq -r ".TargetHealthDescriptions[] | select(.Target.Id == \"$id\") | .TargetHealth.State")
        if [ $TARGETTYPE == "instance" ]; then
            hostname=$(ec2-instance-show-name-from-id $id)
            echo -e "$hostname\t$id\t$status"
        else
            echo -e "$id\t$status"
        fi
    done
}        

elb-tg-for-host() {
    TARGET_NAME=$1
    TARGET_ID=$(ec2-instance-show-id $TARGET_NAME)
    TG_ARNS=$(elb-tg-list-arn)
    TGS_WITH_TARGET=''
    for arn in $TG_ARNS; do
        RESPONSE=$(aws elbv2 describe-target-health --target-group-arn $arn)
        echo $RESPONSE | grep "$TARGET_ID" > /dev/null 2>&1 && TGS_WITH_TARGET="$arn $TGS_WITH_TARGET" 
    done
    for arn in $TGS_WITH_TARGET; do
        echo $arn | awk -F'/' '{print $2}'
    done
}
    

#aws elbv2 describe-target-group-attributes --target-group-arn $(elb-tg-show-arn uc3-mrtstore-pvt-prd-tg)
#aws elbv2 modify-target-group-attributes --target-group-arn $(elb-tg-show-arn uc3-dryad-dev-tg) --attributes Key=deregistration_delay.timeout_seconds,Value=30

elb-tg-show-attributes() {
    TG=$1
    aws elbv2 describe-target-group-attributes --target-group-arn $(elb-tg-show-arn $TG) | \
        jq -r '.Attributes[] | [.Key, .Value] | join(": ")'

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
    if [ -z "$AWS_DEFAULT_REGION" ]; then
        echo "AWS_DEFAULT_REGION not defined"
        return
    fi
    aws elbv2 register-targets --region $AWS_DEFAULT_REGION --target-group-arn $(elb-tg-show-arn $TG) --targets Id=$(ec2-instance-show-id $TARGET)
}

elb-tg-deregister() {
    TG=$1
    TARGET=$2
    if [ -z "$AWS_DEFAULT_REGION" ]; then
        echo "AWS_DEFAULT_REGION not defined"
        return
    fi
    aws elbv2 deregister-targets --region $AWS_DEFAULT_REGION --target-group-arn $(elb-tg-show-arn $TG) --targets Id=$(ec2-instance-show-id $TARGET)
}


# ALB Listeners

# Argument is an ALB name
elb-listener-for-alb() {
    NAME=$1
    ARN=$(elb-lb-show-arn $NAME)
    $AWSBIN elbv2 describe-listeners --load-balancer-arn $ARN
} 

elb-listener-for-alb-show-arn() {
    NAME=$1
    elb-listener-for-alb $NAME | yq -r '.Listeners[].ListenerArn'
} 

elb-listener-rules-for-alb() {
    NAME=$1
    RULE_ARNS=$(elb-listener-for-alb-show-arn  $NAME)
    for arn in $RULE_ARNS; do
        echo "ListenerArn: $arn"
        $AWSBIN elbv2 describe-rules --listener-arn $arn
        echo
    done
}


