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

ec2-instance-tags() {
    INSTANCE_ID=$(ec2-metadata -i| awk {'print $2}')
    EC2TAGS=$(aws ec2 describe-tags --filter Name=resource-id,Values=${INSTANCE_ID})
    echo $EC2TAGS | jq -r '.Tags[] | [.Key, .Value] | join("=")'
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
    aws elbv2 describe-target-groups | jq -r ".TargetGroups[] | select(.TargetGroupName == \"$NAME\")"
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

# get tags for elb
elb-lb-show-tags() {
    REGION=us-west-2
    LB=$1
    aws elbv2 describe-tags --resource-arns $(elb-lb-show-arn $LB) | jq -r '.TagDescriptions[].Tags[]'
}

# get tags for tg
elb-tg-show-tags() {
    REGION=us-west-2
    TG=$1
    aws elbv2 describe-tags --resource-arns $(elb-tg-show-arn $TG) | jq -r '.TagDescriptions[].Tags[]'
}

# Return targetgroup name for calling ec2 instance
elb-tg-for-instance() {

    eval $(ec2-instance-tags)
    echo $Program
    echo $Service
    echo $Subservice
    echo $Environment

    #declare -a TG_TAGS
    for tg_arn in $(elb-tg-list-arn); do
        #TG_TAGS=( "${TG_TAGS[@]}" "$(aws elbv2 describe-tags --resource-arns $tg_arn | jq -r '.TagDescriptions[]')" )

        tgtags=$(aws elbv2 describe-tags --resource-arns $tg_arn | jq -r '.TagDescriptions[]')
        tgprogram=$(echo ${tgtags} | jq -r '.Tags[] | select(.Key=="Program") | .Value')
        tgservice=$(echo ${tgtags} | jq -r '.Tags[] | select(.Key=="Service") | .Value')
        tgsubservice=$(echo ${tgtags} | jq -r '.Tags[] | select(.Key=="Subservice") | .Value')
        tgenvironment=$(echo ${tgtags} | jq -r '.Tags[] | select(.Key=="Environment") | .Value')

        #echo $tg_arn
        #echo $tgprogram
        #echo $tgservice
        #echo $tgsubservice
        #echo $tgenvironment
        echo
        if [ "$Program" == "$tgprogram" ] && [ "$Service" == "$tgservice" ] && [ "$Subservice" == "$tgsubservice" ]  && [ "$myenvironment" == "$tgenvironment" ] ; then
            echo $tg_arn
        fi

    done

}




#tg_tags=$(for lbarn in $(elb-lb-list-arn); do aws elbv2 describe-tags --resource-arns $lbarn; done)
