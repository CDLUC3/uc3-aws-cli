# Cloudwatch Logs query functions

cwlog-lg-list() {
    response=$(aws logs list-log-groups)
    loggroups=$(echo "$response" | jq -r '.logGroups[].logGroupName')
    nexttoken=$(echo "$response" | jq -r '.nextToken')
    while [ "$nexttoken" != "null" ]; do
        response=$(aws logs list-log-groups --next-token $nexttoken)
        loggroups="${loggroups} $(echo "$response" | jq -r '.logGroups[].logGroupName')"
        nexttoken=$(echo "$response" | jq -r '.nextToken')
    done
    # convert spaces into end-of-line and sort
    echo "${loggroups// /$'\n'}" | sort
}

cwlog-lg-show() {
    LG_NAME=$1
    $AWSBIN logs describe-log-groups --log-group-name-prefix $LG_NAME
}

cwlog-ls-list() {
    LG_NAME=$1
    $AWSBIN logs describe-log-streams --log-group-name $LG_NAME --order-by LastEventTime --descending \
       | yq -r '.logStreams[].logStreamName'
}

cwlog-ls-show() {
    LG_NAME=$1
    LS_NAME=$2
    $AWSBIN logs describe-log-streams --log-group-name $LG_NAME --log-stream-name-prefix $LS_NAME
}

cwlog-ls-show-latest() {
    LG_NAME=$1
    $AWSBIN logs describe-log-streams --log-group-name $LG_NAME --order-by LastEventTime --descending \
       | yq -ry '.logStreams[0]'

}

cwlog-ls-list-latest() {
    LG_NAME=$1
    cwlog-ls-latest-show $LG_NAME | yq -r '.logStreamName'
}

# > aws logs get-log-events --log-group-name /aws/lambda/SinatraLambda-blee  --log-stream-name 'ashtest_0'
cwlog-events-get() {
    LG_NAME=$1
    LS_NAME=$2
    aws logs get-log-events --log-group-name $LG_NAME --log-stream-name $LS_NAME --limit 10
    #$AWSBIN logs get-log-events --log-group-name $LG_NAME --log-stream-name $LS_NAME --limit 10
}

cwlog-events-get-latest() {
    LG_NAME=$1
    LS_NAME=$(cwlog-ls-list-latest $LG_NAME)
    aws logs get-log-events --log-group-name $LG_NAME --log-stream-name $LS_NAME --limit 10
}


# aws logs describe-subscription-filters  --log-group-name


## These commands alter resources

cwlog-lg-create() {
    LG_NAME=$1
    $AWSBIN logs create-log-group --log-group-name $LG_NAME
}

cwlog-ls-create() {
    LG_NAME=$1
    LS_NAME=$2
    $AWSBIN logs create-log-stream --log-group-name $LG_NAME --log-stream-name $LS_NAME
}

cwlog-lg-delete() {
    LG_NAME=$1
    $AWSBIN logs delete-log-group --log-group-name $LG_NAME
}

cwlog-events-put() {
    LG_NAME=$1
    LS_NAME=$2
    EVENTS_FILE=$3
    $AWSBIN logs put-log-events --log-group-name $LG_NAME --log-events file://${EVENTS_FILE} --log-stream-name $LS_NAME
}

# usage:
# cwlog-lg-create /test/ashley/kfd2oass
# cwlog-ls-create /test/ashley/kfd2oass stream00
# ~/cdl/ops/opensearch/fluentbit/pipeline_for_cloudwatch_logs> bin/generate_log_data.py 10 | tee data/generated_log_data.json
# cwlog-events-put /test/ashley/kfd2oass stream00 ~/cdl/ops/opensearch/fluentbit/pipeline_for_cloudwatch_logs/data/generated_log_data.json 
#
# 

########################################
# Notes
########################################

#describe-subscription-filters
#
#filter-log-events
#
#put-subscription-filter


#put-log-events

# first create input file. timestamp must be less than 14 days old and
# formatted as milliseconds since unix epoch:

# agould@localhost:~> date +%s%3N
# 1755892465925
# agould@localhost:~> date +%s%3N
# 1755892470773
# agould@localhost:~> date +%s%3N
# 1755892471829
# 
# agould@localhost:~> cat /tmp/cwlog_test_events.json
# [
#   {
#     "timestamp": 1755892465925,
#     "message": "Example Event 1"
#   },
#   {
#     "timestamp": 1755892470773,
#     "message": "Example Event 2"
#   },
#   {
#     "timestamp": 1755892471829,
#     "message": "Example Event 3"
#   }
# ]
# 
# > aws logs put-log-events --log-group-name /aws/lambda/SinatraLambda-blee --log-events file:///tmp/cwlog_test_events.json --log-stream-name 'ashtest_0'
# {
#     "nextSequenceToken": "49664317072078038044025136353663496102325877620349076402"
# }


# get-log-events
#
# > aws logs get-log-events --log-group-name /aws/lambda/SinatraLambda-blee  --log-stream-name 'ashtest_0'
# {
#     "events": [
#         {
#             "timestamp": 1755892465925,
#             "message": "Example Event 1",
#             "ingestionTime": 1755892617842
#         },
#         {
#             "timestamp": 1755892470773,
#             "message": "Example Event 2",
#             "ingestionTime": 1755892617842
#         },
#         {
#             "timestamp": 1755892471829,
#             "message": "Example Event 3",
#             "ingestionTime": 1755892617842
#         }
#     ],
#     "nextForwardToken": "f/39157710610276639208865565599033931292223254949281136642/s",
#     "nextBackwardToken": "b/39157710478613039556740766571407050610507328617972760576/s"
# }

