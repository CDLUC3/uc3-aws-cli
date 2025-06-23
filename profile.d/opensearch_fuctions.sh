# Shell fuctions for querying OpenSearch
#

os-domain-list() {
    $AWSBIN opensearch list-domain-names | yq -r '.DomainNames[].DomainName'
}

os-domain-show() {
    NAME=$1
    $AWSBIN --output yaml opensearch describe-domain --domain-name $NAME
}

os-domain-show-config() {
    NAME=$1
    $AWSBIN --output yaml opensearch describe-domain-config --domain-name $NAME
}

os-domain-update() {
    NAME=$1
    $AWSBIN opensearch start-service-software-update --domain-name $NAME
}


# Functions for AWS OpenSearch Serverless (aoss)

aoss-access-policy-list() {
    $AWSBIN opensearchserverless list-access-policies --type data | yq -r '.accessPolicySummaries[].name'
}

aoss-access-policy-show() {
    NAME=$1
    $AWSBIN opensearchserverless get-access-policy --type data --name $NAME
}

aoss-encryption-policy-list() {
    $AWSBIN opensearchserverless list-security-policies --type encryption | yq -r '.securityPolicySummaries[].name'
}

aoss-encryption-policy-show() {
    NAME=$1
    $AWSBIN opensearchserverless get-security-policy --type encryption --name $NAME
}

aoss-network-policy-list() {
    $AWSBIN opensearchserverless list-security-policies --type network | yq -r '.securityPolicySummaries[].name'
}

aoss-network-policy-show() {
    NAME=$1
    $AWSBIN opensearchserverless get-security-policy --type network --name $NAME
}

aoss-security-config-list() {
    $AWSBIN opensearchserverless list-security-configs --type saml | yq -r '.securityConfigSummaries[].id'
    $AWSBIN opensearchserverless list-security-configs --type iamidentitycenter | yq -r '.securityConfigSummaries[].id'
}

aoss-security-config-show() {
    ID=$1
    $AWSBIN opensearchserverless get-security-config --id $ID
}


aoss-collection-list() {
    $AWSBIN opensearchserverless list-collections | yq -r '.collectionSummaries[].name'
}

aoss-collection-show() {
    NAME=$1
    $AWSBIN opensearchserverless batch-get-collection --names $NAME
}

aoss-collection-show-endpoint() {
    NAME=$1
    $AWSBIN opensearchserverless batch-get-collection --names $NAME | yq -r '.collectionDetails[].collectionEndpoint'
}

osis-pipeline-list () {
    $AWSBIN osis list-pipelines | yq -r '.Pipelines[].PipelineName'
}

osis-pipeline-show () {
    NAME=$1
    $AWSBIN osis get-pipeline --pipeline-name $NAME #| yq -r '.Pipelines[].PipelineName'
}

osis-blueprint-list () {
    $AWSBIN osis list-pipeline-blueprints | yq -r '.Blueprints[].BlueprintName'
    # aws osis get-pipeline-blueprint --blueprint-name AWS-ElbAccessLogS3Pipeline
}

