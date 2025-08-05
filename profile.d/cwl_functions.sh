# Cloudwatch Logs query functions

cwl-log-groups-list() {
    response=$(aws logs list-log-groups)
    loggroups=$(echo "$response" | jq -r '.logGroups[]')
    nexttoken=$(echo "$response" | jq -r '.nextToken')
    while [ ! -n $nexttoken ]; do
        response=$(aws logs list-log-groups --next-token $nexttoken)
        loggroups=${loggroups}$(echo "$response" | jq -r '.logGroups[]')
        nexttoken=$(echo "$response" | jq -r '.nextToken')
    done
    echo $loggroups | jq -r '.logGroupName' | sort
}

#describe-subscription-filters
#
#describe-log-groups
#
#filter-log-events
#
#get-log-events
#
#put-log-events
#
#put-subscription-filter


