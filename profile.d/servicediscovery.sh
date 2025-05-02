# servicediscovery.sh

sd_namespace_list() {
    $AWSBIN servicediscovery list-namespaces | yq -r .Namespaces[].Name
} 

sd_namespace_show_id() {
    NAMESPACE=$1
    EXPR="$AWSBIN servicediscovery list-namespaces --query 'Namespaces[?Name==\`$NAMESPACE\`].Id'"
    eval $EXPR | yq -r .[]
} 

sd_namespace_show() {
    NAMESPACE=$1
    NAMESPACE_ID=$(sd_namespace_show_id $NAMESPACE)
    $AWSBIN servicediscovery get-namespace --id $NAMESPACE_ID
} 

sd_service_list() {
    NAMESPACE=$1
    NAMESPACE_ID=$(sd_namespace_show_id $NAMESPACE)
    $AWSBIN servicediscovery list-services --filters Name=NAMESPACE_ID,Values=$NAMESPACE_ID | \
         yq -r .Services[].Name
} 

sd_service_show_id() {
    NAMESPACE=$1
    SERVICE=$2
    NAMESPACE_ID=$(sd_namespace_show_id $NAMESPACE)
    $AWSBIN servicediscovery list-services --filters Name=NAMESPACE_ID,Values=$NAMESPACE_ID | \
         yq -r ".Services[] | select(.Name == \"$SERVICE\") | .Id"
} 

sd_service_show() {
    NAMESPACE=$1
    SERVICE=$2
    SERVICE_ID=$(sd_service_show_id $NAMESPACE $SERVICE)
    $AWSBIN servicediscovery get-service --id $SERVICE_ID
} 

sd_instance_show() {
    NAMESPACE=$1
    SERVICE=$2
    $AWSBIN servicediscovery discover-instances --namespace-name $NAMESPACE --service-name $SERVICE 
}

sd_instance_show_ipaddr() {
    NAMESPACE=$1
    SERVICE=$2
    sd_instance_show $NAMESPACE $SERVICE | yq -r ".Instances[].Attributes.AWS_INSTANCE_IPV4"
}


# ~ $ ui=$(aws servicediscovery discover-instances \
#           --service-name ui --namespace-name merritt | \
#           jq -r ".Instances[0].Attributes.AWS_INSTANCE_IPV4")
# ~ $ curl http://$ui:8086/state.json
# {
#   "version": "Docker Build Tue Apr 29 10:54:10 PDT 202",
#   "start_time": "2025-04-29T10:56:24-0700"
# }
