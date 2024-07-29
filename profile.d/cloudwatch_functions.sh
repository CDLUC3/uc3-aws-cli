# CloudWatch Query functions

cw-metric-list-namespaces() {
    $AWSBIN cloudwatch list-metrics | yq -r ".Metrics[].Namespace" | sort -u
}

cw-metric-list-by-namespace() {
    NAMESPACE=$1
    $AWSBIN cloudwatch list-metrics --namespace $NAMESPACE | yq -r ".Metrics[].MetricName" | sort -u
    #$AWSBIN cloudwatch list-metrics | yq -r ".Metrics[] | select(.Namespace == \"$NAMESPACE\") | .MetricName" | sort
}


cw-metric-show() {
    NAMESPACE=$1
    METRICNAME=$2
    $AWSBIN cloudwatch list-metrics --namespace $NAMESPACE --metric-name $METRICNAME
}


cw-metric-show-statistics() {
    NAMESPACE=$1
    METRICNAME=$2
    $AWSBIN cloudwatch get-metric-statistics --namespace $NAMESPACE --metric-name $METRICNAME
}
