# Shell fuctions for querying OpenSearch
#

os-domain-list() {
    $AWSBIN opensearch list-domain-names | yq -r '.DomainNames[].DomainName'
}

os-domain-show() {
    NAME=$1
    $AWSBIN opensearch describe-domain --domain-name $NAME
}

os-domain-show-config() {
    NAME=$1
    $AWSBIN opensearch describe-domain-config --domain-name $NAME
}

os-domain-update() {
    NAME=$1
    $AWSBIN opensearch start-service-software-update --domain-name $NAME
}
