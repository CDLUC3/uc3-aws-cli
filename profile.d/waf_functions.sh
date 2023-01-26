# Shell functions for querying wafv2 resources
#

waf-webacl-list() {
    echo Regional WebACLs:
    RESPONSE=$(aws wafv2 list-web-acls --scope REGIONAL)
    echo $RESPONSE | jq -r ".WebACLs[].Name"
    NEXTMARKER=$(echo $RESPONSE | jq -r .NextMarker)
    while [ ! "$NEXTMARKER" == "null" ]; do
        RESPONSE=$(aws wafv2 list-web-acls --scope REGIONAL --next-marker $NEXTMARKER)
        echo $RESPONSE | jq -r ".WebACLs[].Name"
        NEXTMARKER=$(echo $RESPONSE | jq -r .NextMarker)
    done
    echo
    echo CloudFront WebACLs:
    RESPONSE=$(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1)
    echo $RESPONSE | jq -r ".WebACLs[].Name"
    NEXTMARKER=$(echo $RESPONSE | jq -r .NextMarker)
    while [ ! "$NEXTMARKER" == "null" ]; do
        RESPONSE=$(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 --next-marker $NEXTMARKER)
        echo $RESPONSE | jq -r ".WebACLs[].Name"
        NEXTMARKER=$(echo $RESPONSE | jq -r .NextMarker)
    done
}


waf-webacl-show-scope() {
    WEBACL_NAME=$1
    RESPONSE=$(aws wafv2 list-web-acls --scope REGIONAL)
    WEBACL=$(echo $RESPONSE | jq -r ".WebACLs[] | select(.Name == \"$WEBACL_NAME\")")
    if [ -n "$WEBACL" ]; then
        echo "REGIONAL"
    else
        RESPONSE=$(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1)
        WEBACL=$(echo $RESPONSE | jq -r ".WebACLs[] | select(.Name == \"$WEBACL_NAME\")")
        if [ -n "$WEBACL" ]; then
            echo "CLOUDFRONT --region us-east-1"
        fi
    fi
}

waf-webacl-show-id() {
    WEBACL_NAME=$1
    SCOPE=$(waf-webacl-show-scope $WEBACL_NAME)
    if [ -n "$SCOPE" ]; then
        RESPONSE=$(aws wafv2 list-web-acls --scope $SCOPE)
        echo $RESPONSE | jq -r ".WebACLs[] | select(.Name == \"$WEBACL_NAME\") | .Id"
    fi
}

waf-webacl-show-arn() {
    WEBACL_NAME=$1
    SCOPE=$(waf-webacl-show-scope $WEBACL_NAME)
    if [ -n "$SCOPE" ]; then
        RESPONSE=$(aws wafv2 list-web-acls --scope $SCOPE)
        echo $RESPONSE | jq -r ".WebACLs[] | select(.Name == \"$WEBACL_NAME\") | .ARN"
    fi
}

waf-webacl-show() {
    WEBACL_NAME=$1
    SCOPE=$(waf-webacl-show-scope $WEBACL_NAME)
    if [ -n "$SCOPE" ]; then
        WEBACL_ID=$(waf-webacl-show-id $WEBACL_NAME)
        aws wafv2 get-web-acl --name $WEBACL_NAME --id $WEBACL_ID --scope $SCOPE
    fi
}

waf-webacl-for-elb() {
    ELB_ARN=$(elb-lb-show-arn $1)
    if [ -n "$ELB_ARN" ]; then
        aws wafv2 get-web-acl-for-resource --resource-arn $ELB_ARN
    fi
}

waf-webacl-show-tags() {
    WEBACL_NAME=$1
    SCOPE=$(waf-webacl-show-scope $WEBACL_NAME)
    if [ -n "$SCOPE" ]; then
        WEBACL_ARN=$(waf-webacl-show-arn $WEBACL_NAME)
        if [ "$SCOPE" == "REGIONAL" ]; then
            RESPONSE=$(aws wafv2 list-tags-for-resource --resource-arn $WEBACL_ARN)
        else
            RESPONSE=$(aws wafv2 list-tags-for-resource --resource-arn $WEBACL_ARN --region us-east-1)
        fi
        #echo $RESPONSE | jq -r ".TagInfoForResource.TagList[]"
        echo $RESPONSE | jq -r ".TagInfoForResource"
    fi
}

waf-webacl-list-rules() {
    WEBACL_NAME=$1
    SCOPE=$(waf-webacl-show-scope $WEBACL_NAME)
    if [ -n "$SCOPE" ]; then
        WEBACL_ID=$(waf-webacl-show-id $WEBACL_NAME)
        RESPONSE=$(aws wafv2 get-web-acl --name $WEBACL_NAME --id $WEBACL_ID --scope $SCOPE)
        echo $RESPONSE | jq -r ".WebACL.Rules[].VisibilityConfig.MetricName"
    fi
}

waf-webacl-show-rule-samples() {
    WEBACL_NAME=$1
    SCOPE=$(waf-webacl-show-scope $WEBACL_NAME)
    if [ -n "$SCOPE" ]; then
        SEC=10800
        START=$((`date '+%s'` - $SEC ))
        START2=`date -u -d "@$START" '+%Y-%m-%dT%H:%MZ'`
        NOW=`date -u '+%Y-%m-%dT%H:%MZ'`
        WEBACL_ARN=$(waf-webacl-show-arn $WEBACL_NAME)
        WEBACL_RULES=$(waf-webacl-show-rules $WEBACL_NAME)
        for rule in $WEBACL_RULES; do
            echo $rule
            aws wafv2 get-sampled-requests \
                --web-acl-arn $WEBACL_ARN \
                --scope $SCOPE \
                --time-window StartTime="$START2",EndTime="$NOW" \
                --rule-metric-name $rule \
                --max-items 500 | jq .
        done
    fi
}





#
#SEC=$((${1:-180} * 60))
#START=$((`date '+%s'` - $SEC ))
#START=`date -u -d "@$START" '+%Y-%m-%dT%H:%MZ'`
#NOW=`date -u '+%Y-%m-%dT%H:%MZ'`
#for rule in "CrossSiteScripting_BODY" "GenericLFI_BODY" "GenericRFI_BODY" "NoUserAgent_HEADER" "RestrictedExtensions_URIPATH" "SizeRestrictions_BODY" "LFI_QUERYSTRING" "LFI_URIPATH"
#do
#        echo "$START - $NOW"
#        echo "$rule"
#        aws wafv2 get-sampled-requests --web-acl-arn arn:aws:wafv2:us-west-2:451826914157:regional/webacl/uc3-mrtui-stg-waf/ec1c9a4c-0c18-4f2e-83d4-bbe4a7d44136 --rule-metric-name $rule --scope REGIONAL --time-window StartTime="$START",EndTime="$NOW" --max-items 500 | jq .
#done 

# cat ~/tmp/wafv2_metrics | jq -r ".Metrics[] | select(.Dimensions[] | select(.Name == \"WebACL\" and .Value == \"uc3-dmptool-stg-waf\"))"
#
# https://docs.aws.amazon.com/waf/latest/developerguide/monitoring-cloudwatch.html
