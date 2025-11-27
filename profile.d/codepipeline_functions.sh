# Query functions for codepipeline, codebuild, and codestar-connections

# codestar-connections
costar-connection-list () {
  $AWSBIN codestar-connections list-connections | yq -r .Connections[].ConnectionName
}

costar-connection-show () {
  CONNECTION_NAME=$1
  CONNECTION_ARN=$($AWSBIN codestar-connections list-connections | \
	  yq -r ".Connections[] | select(.ConnectionName == \"$CONNECTION_NAME\") | .ConnectionArn")
  #echo $CONNECTION_ARN
  $AWSBIN codestar-connections get-connection --connection-arn $CONNECTION_ARN
  $AWSBIN codestar-connections list-tags-for-resource --resource-arn $CONNECTION_ARN
}

