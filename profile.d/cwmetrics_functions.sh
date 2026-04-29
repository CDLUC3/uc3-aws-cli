# cloudwatch queries for metrics and alarms
#
cwmetrics-alarm-list() {
  $AWSBIN cloudwatch describe-alarms | yq -r '.MetricAlarms[].AlarmName'
}	

cwmetrics-alarm-show() {
  ALARM_NAME=$1
  $AWSBIN cloudwatch describe-alarms --alarm-names $ALARM_NAME
}


cwmetrics-namespace-list() {
NAMESPACES="AWS/AOSS AWS/ApiGateway AWS/ApplicationELB AWS/Backup AWS/Bedrock-AgentCore AWS/CertificateManager AWS/Cognito AWS/Config AWS/DynamoDB AWS/EBS AWS/EC2 AWS/ECR AWS/ECS AWS/EFS AWS/ES AWS/ElastiCache AWS/Events AWS/Firehose AWS/HealthLake AWS/KMS AWS/Kinesis AWS/Lambda AWS/Logs AWS/Observability Admin AWS/PrivateLinkEndpoints AWS/RDS AWS/S3 AWS/SNS AWS/SQS AWS/SSM-RunCommand AWS/SecretsManager AWS/States AWS/Usage AWS/WAFV2 AWS/X-Ray CWAgent ECS/ContainerInsights merritt"
for n in $NAMESPACES; do
  echo $n
done
}

cwmetrics-metric-for-namespace-list() {
  NAME_SPACE=$1
  $AWSBIN cloudwatch list-metrics --namespace $NAME_SPACE
}		
  


