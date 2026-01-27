# Query functions for codepipeline, codebuild, and codestar-connections

# codestar-connections
codestar-connection-list () {
  $AWSBIN codestar-connections list-connections | yq -r .Connections[].ConnectionName
}

codestar-connection-show () {
  CONNECTION_NAME=$1
  CONNECTION_ARN=$($AWSBIN codestar-connections list-connections | \
	  yq -r ".Connections[] | select(.ConnectionName == \"$CONNECTION_NAME\") | .ConnectionArn")
  #echo $CONNECTION_ARN
  $AWSBIN codestar-connections get-connection --connection-arn $CONNECTION_ARN
  $AWSBIN codestar-connections list-tags-for-resource --resource-arn $CONNECTION_ARN
}

codebuild-project-list() {
  $AWSBIN codebuild list-projects
}

codepipeline-pipeline-list() {
  $AWSBIN codepipeline list-pipelines | yq -r .pipelines[].name
}

codepipeline-pipeline-show() {
  PIPELINE_NAME=$1
  $AWSBIN codepipeline get-pipeline --name $PIPELINE_NAME
}

codepipeline-pipeline-show-state() {
  PIPELINE_NAME=$1
  $AWSBIN codepipeline get-pipeline-state --name $PIPELINE_NAME
}

codepipeline-pipeline-execution-list() {
  PIPELINE_NAME=$1
  $AWSBIN codepipeline list-pipeline-executions --pipeline-name $PIPELINE_NAME
}

codepipeline-pipeline-execution-start() {
  PIPELINE_NAME=$1
  $AWSBIN codepipeline start-pipeline-execution --name $PIPELINE_NAME
}

codepipeline-pipeline-execution-show() {
  PIPELINE_NAME=$1
  EXECUTION_ID=$2
  $AWSBIN codepipeline get-pipeline-execution --pipeline-name $PIPELINE_NAME --pipeline-execution-id $EXECUTION_ID
}



