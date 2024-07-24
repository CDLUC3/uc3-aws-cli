# Shell fuctions for querying OpenSearch
#

os-versions-list() {
    aws opensearch list-versions
}

os-domain-list() {
    $AWSBIN opensearch list-domain-names | yq -r '.DomainNames[].DomainName'
}

os-domain-show() {
    NAME=$1
    $AWSBIN opensearch describe-domain --domain-name $NAME
}

os-domain-show-arn() {
    NAME=$1
    $AWSBIN opensearch describe-domain --domain-name $NAME | yq -r .DomainStatus.ARN
}

os-domain-show-tags() {
    NAME=$1
    ARN=$(os-domain-show-arn $NAME)
    $AWSBIN opensearch list-tags --arn $ARN
}

os-domain-show-config() {
    NAME=$1
    $AWSBIN opensearch describe-domain-config --domain-name $NAME
}

os-domain-update() {
    NAME=$1
    $AWSBIN opensearch start-service-software-update --domain-name $NAME
}

os-domain-show-upgrade-versions() {
    NAME=$1
    VERSION=$2
    $AWSBIN opensearch get-compatible-versions --domain-name $NAME
}

os-scheduled-actions-list() {
    NAME=$1
    $AWSBIN opensearch list-scheduled-actions --domain-name $NAME
}

# An error occurred (AccessDeniedException) when calling the UpgradeDomain operation: [User: arn:aws:sts::451826914157:assumed-role/uc3-aws-ops/i-097c2bb827b182cf3 is not authorized to perform: es:UpgradeDomain on resource: arn:aws:es:us-west-2:451826914157:domain/os-uc3-logging-stg
os-domain-upgrade() {
    NAME=$1
    VERSION=$2
    $AWSBIN opensearch upgrade-domain --domain-name $NAME --target-version $VERSION --perform-check-only
}

#After testing your changes I find there are more permissions I am missing.  Please add also:
#```
#es:GetCompatibleElasticsearchVersions
#es:ListVersions
#es:ListElastisearchVersions
#```






#agould@uc3-aws2023-ops:~/git/github/cdluc3/uc3-aws-cli/profile.d> aws opensearch describe-domain-health --domain-name os-uc3-logging-stg
#
#An error occurred (AccessDeniedException) when calling the DescribeDomainHealth operation: User: arn:aws:sts::451826914157:assumed-role/uc3-aws-ops/i-097c2bb827b182cf3 is not authorized to perform: es:DescribeDomainHealth on resource: arn:aws:es:us-west-2:451826914157:domain/os-uc3-logging-stg because no identity-based policy allows the es:DescribeDomainHealth action
#
#agould@uc3-aws2023-ops:~/git/github/cdluc3/uc3-aws-cli/profile.d> aws opensearch describe-domain-nodes --domain-name os-uc3-logging-stg

#An error occurred (AccessDeniedException) when calling the DescribeDomainNodes operation: User: arn:aws:sts::451826914157:assumed-role/uc3-aws-ops/i-097c2bb827b182cf3 is not authorized to perform: es:DescribeDomainNodes on resource: arn:aws:es:us-west-2:451826914157:domain/os-uc3-logging-stg because no identity-based policy allows the es:DescribeDomainNodes action

# agould@uc3-aws2023-ops:~/git/github/cdluc3/uc3-aws-cli/profile.d> aws opensearch get-compatible-versions --domain-name os-uc3-logging-stg

# An error occurred (AccessDeniedException) when calling the GetCompatibleVersions operation: [User: arn:aws:sts::451826914157:assumed-role/uc3-aws-ops/i-097c2bb827b182cf3 is not authorized to perform: es:GetCompatibleVersions
#
#
# agould@uc3-aws2023-ops:~/git/github/cdluc3/uc3-aws-cli/profile.d> aws opensearch list-scheduled-actions --domain-name os-uc3-logging-stg

# An error occurred (AccessDeniedException) when calling the ListScheduledActions operation: User: arn:aws:sts::451826914157:assumed-role/uc3-aws-ops/i-097c2bb827b182cf3 is not authorized to perform: es:ListScheduledActions 
#
#
# ApiError
# User: arn:aws:sts::451826914157:assumed-role/AWSReservedSSO_cdl-reports_0e48e1ad8bce75a9/agould is not authorized to perform: es:ListNotificationsV2 on resource: arn:aws:es:us-east-1:451826914157:domain/* because no identity-based policy allows the es:ListNotificationsV2 action
