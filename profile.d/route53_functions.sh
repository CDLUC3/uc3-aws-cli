#!/usr/bin/env bash

# Route53

route53-hz-list-public() {
    aws route53 list-hosted-zones-by-name --query 'HostedZones[?Config.PrivateZone==`false`].Name'
}

route53-hz-list-private() {
    aws route53 list-hosted-zones-by-name --query 'HostedZones[?Config.PrivateZone==`true`].Name'
}

route53-hz-list() {
    PUBLIC_HZ=$(route53-hz-list-public)
    PRIVATE_HZ=$(route53-hz-list-private)
    echo "Public:"
    echo "$PUBLIC_HZ"
    echo
    echo "Private:"
    echo "$PRIVATE_HZ"
}

route53-hz-show-id() {
    DOMAIN_NAME=${1%%.}.
    EXPR="aws route53 list-hosted-zones --query 'HostedZones[?Name==\`$DOMAIN_NAME\`].{Id: Id, PrivateZone: Config.PrivateZone}'"
    eval $EXPR
}

route53-hz-show-id-public() {
    DOMAIN_NAME=${1%%.}.
    EXPR="aws route53 list-hosted-zones --query 'HostedZones[?Config.PrivateZone==\`false\` && Name==\`$DOMAIN_NAME\`].Id'"
    eval $EXPR | jq -r .[] | awk -F'/' '{print $3}'
}

route53-hz-show-id-private() {
    DOMAIN_NAME=${1%%.}.
    EXPR="aws route53 list-hosted-zones --query 'HostedZones[?Config.PrivateZone==\`true\` && Name==\`$DOMAIN_NAME\`].Id'"
    eval $EXPR | jq -r .[] | awk -F'/' '{print $3}'
}

route53-hz-show() {
    ZONE_IDS=$(route53-hz-show-id $1)
    PUBLIC_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == false) | .Id' | awk -F'/' '{print $3}')
    PRIVATE_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == true) | .Id' | awk -F'/' '{print $3}')
    if [ -n "$PUBLIC_ID" ]; then
        echo Public Hosted Zone:
        aws route53 get-hosted-zone --id $PUBLIC_ID | jq -r
        echo
    fi
    if [ -n "$PRIVATE_ID" ]; then
        echo Private Hosted Zone:
        aws route53 get-hosted-zone --id $PRIVATE_ID | jq -r
    fi
}

route53-hz-show-public() {
    HOSTED_ZONE_ID=$(route53-hz-show-id-public $1)
    if [ -n "$HOSTED_ZONE_ID" ]; then
        aws route53 get-hosted-zone --id $HOSTED_ZONE_ID | jq -r
    fi
}

route53-hz-show-private() {
    HOSTED_ZONE_ID=$(route53-hz-show-id-private $1)
    if [ -n "$HOSTED_ZONE_ID" ]; then
        aws route53 get-hosted-zone --id $HOSTED_ZONE_ID | jq -r
    fi
}

route53-recordset-list() {
    ZONE_IDS=$(route53-hz-show-id $1)
    PUBLIC_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == false) | .Id' | awk -F'/' '{print $3}')
    PRIVATE_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == true) | .Id' | awk -F'/' '{print $3}')    
    if [ -n "$PUBLIC_ID" ]; then
        echo Public Hosted Zone:
        aws route53 list-resource-record-sets --hosted-zone-id $PUBLIC_ID | jq -r '.ResourceRecordSets[].Name'
        echo
    fi
    if [ -n "$PRIVATE_ID" ]; then
        echo Private Hosted Zone:
        aws route53 list-resource-record-sets --hosted-zone-id $PRIVATE_ID | jq -r '.ResourceRecordSets[].Name'
    fi
}

route53-recordset-list-public() {
    HOSTED_ZONE_ID=$(route53-hz-show-id-public $1)
    aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID
    #aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID | jq -r '.ResourceRecordSets[]'
}

route53-recordset-list-private() {
    HOSTED_ZONE_ID=$(route53-hz-show-id-private $1)
    aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID
    #aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID | jq -r
}


route53-recordset-show() {
    if [ $# -ne 2 ]; then
        echo "Usage: route53-recordset-show <domain_name> <host_name>"
        return
    fi
    DOMAIN_NAME=${1%%.}.
    HOST_NAME=${2%%.}.
    FQDN=${HOST_NAME%%$DOMAIN_NAME}$DOMAIN_NAME
    #echo $FQDN
    ZONE_IDS=$(route53-hz-show-id $DOMAIN_NAME)
    PUBLIC_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == false) | .Id' | awk -F'/' '{print $3}')
    PRIVATE_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == true) | .Id' | awk -F'/' '{print $3}')    
    if [ -n "$PUBLIC_ID" ]; then
        echo Public Hosted Zone:
        aws route53 list-resource-record-sets --hosted-zone-id $PUBLIC_ID | jq -r ".ResourceRecordSets[] | select(.Name == \"$FQDN\")"
        echo
    fi
    if [ -n "$PRIVATE_ID" ]; then
        echo Private Hosted Zone:
        aws route53 list-resource-record-sets --hosted-zone-id $PRIVATE_ID | jq -r ".ResourceRecordSets[] | select(.Name == \"$FQDN\")"
    fi
}


route53-recordset-show-cname() {
    if [ $# -ne 2 ]; then
        echo "Usage: route53-recordset-show-cname <domain_name> <cname_target>"
        return
    fi
    DOMAIN_NAME=${1%%.}.
    TARGET=$2
    ZONE_IDS=$(route53-hz-show-id $DOMAIN_NAME)
    PUBLIC_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == false) | .Id' | awk -F'/' '{print $3}')
    PRIVATE_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == true) | .Id' | awk -F'/' '{print $3}')    
    if [ -n "$PUBLIC_ID" ]; then
        echo Public Hosted Zone:
        aws route53 list-resource-record-sets --hosted-zone-id $PUBLIC_ID | jq -r ".ResourceRecordSets[] | select(.Type == \"CNAME\") | select(.ResourceRecords[].Value | test(\"$TARGET\"))"
        echo
    fi
    if [ -n "$PRIVATE_ID" ]; then
        echo Private Hosted Zone:
        aws route53 list-resource-record-sets --hosted-zone-id $PRIVATE_ID | jq -r ".ResourceRecordSets[] | select(.Type == \"CNAME\") | select(.ResourceRecords[].Value | test(\"$TARGET\"))"
    fi
}


route53-recordset-show-alias() {
    if [ $# -ne 2 ]; then
        echo "Usage: route53-recordset-show-alias <domain_name> <alias_target>"
        return
    fi
    DOMAIN_NAME=${1%%.}.
    TARGET=$2
    ZONE_IDS=$(route53-hz-show-id $DOMAIN_NAME)
    PUBLIC_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == false) | .Id' | awk -F'/' '{print $3}')
    PRIVATE_ID=$(echo $ZONE_IDS | jq -r '.[] | select(.PrivateZone == true) | .Id' | awk -F'/' '{print $3}')    
    if [ -n "$PUBLIC_ID" ]; then
        echo Public Hosted Zone:
        aws route53 list-resource-record-sets --hosted-zone-id $PUBLIC_ID | jq -r ".ResourceRecordSets[] | select(.AliasTarget) | select(.AliasTarget.DNSName | test(\"$TARGET\"))"
        echo
    fi
    if [ -n "$PRIVATE_ID" ]; then
        echo Private Hosted Zone:
        aws route53 list-resource-record-sets --hosted-zone-id $PUBLIC_ID | jq -r ".ResourceRecordSets[] | select(.AliasTarget) | select(.AliasTarget.DNSName | test(\"$TARGET\"))"
    fi
}







##############################################################################################
# Notes
#
#

# https://stackoverflow.com/questions/74363977/list-public-hosted-zones-in-aws-route53
# aws route53 list-hosted-zones-by-name --query 'HostedZones[?Config.PrivateZone==`false`].Name'
# aws route53 list-hosetd-zones-by-name --query 'HostedZones[?!(Config.PrivateZone)].Id'
#
# aws route53 list-hosted-zones-by-name --query 'HostedZones[?Config.PrivateZone==`false`]' | jq -r '.[] | select(.Name == "cdlib.org.")'
# aws route53 list-hosted-zones-by-name --query 'HostedZones[?Config.PrivateZone==`false` && Name==`cdlib.org.`]'

#        {
#            "ResourceRecords": [
#                {
#                    "Value": "172.30.20.227"
#                }
#            ], 
#            "Type": "A", 
#            "Name": "dsc-registry2-prd.cdlib.org.", 
#            "TTL": 300
#        }, 
#
#        {
#            "ResourceRecords": [
#                {
#                    "Value": "uc3-ezidui-prd-alb-1936286154.us-west-2.elb.amazonaws.com"
#                }
#            ], 
#            "Type": "CNAME", 
#            "Name": "ezid.cdlib.org.", 
#            "TTL": 300
#        }, 
#
#        {
#            "AliasTarget": {
#                "HostedZoneId": "Z2FDTNDATAQYW2", 
#                "EvaluateTargetHealth": false, 
#                "DNSName": "d32lvbh6ijqboa.cloudfront.net."
#            }, 
#            "Type": "A", 
#            "Name": "www.escholarship-ecai.cdlib.org."
#        }, 


#route53-hz-show-id() {
#    DOMAIN_NAME=${1%%.}.
#    aws route53 list-hosted-zones | 
#        jq -r ".HostedZones[] | select(.Name == \"$DOMAIN_NAME\") | .Id" | \
#        awk -F'/' '{print $3}'
#}
#
#route53-hz-show() {
#    HOSTED_ZONE_ID=$(route53-hz-show-id $1)
#    for ID in $HOSTED_ZONE_ID; do
#        aws route53 get-hosted-zone --id $ID | jq -r
#        echo
#    done
#}
