#!/usr/bin/env bash

# Route53
route53-hz-list() {
    aws route53 list-hosted-zones | jq -r '.HostedZones[].Name'
}

route53-hz-show-id() {
    DOMAIN_NAME=${1%%.}.
    aws route53 list-hosted-zones | \
	jq -r ".HostedZones[] | select(.Name == \"$DOMAIN_NAME\") | .Id" | \
	awk -F'/' '{print $3}'
}

route53-hz-show() {
    HOSTED_ZONE_ID=$(route53-hz-show-id $1)
    #aws route53 get-hosted-zone --id $HOSTED_ZONE_ID | jq -r
    aws --no-cli-pager --output yaml route53 get-hosted-zone --id $HOSTED_ZONE_ID
}

route53-hz-show-recordsets() {
    HOSTED_ZONE_ID=$(route53-hz-show-id $1)
    #aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID | jq -r
    aws --no-cli-pager --output yaml route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID
}

#route53-recordset-show() {
#
#}


#route53-recordset-delete() {
#}



