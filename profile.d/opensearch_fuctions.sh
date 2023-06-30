# Shell fuctions for querying OpenSearch
#

os-domain-list() {
    aws opensearch list-domain-names | jq -r '.DomainNames[].DomainName'
}

os-domain-show() {
    NAME=$1
    aws --output yaml opensearch describe-domain --domain-name $NAME
}

os-domain-show-config() {
    NAME=$1
    aws --output yaml opensearch describe-domain-config --domain-name $NAME
}

