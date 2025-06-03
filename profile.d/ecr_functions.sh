# ecr_functions
#

ecr_repository_list () {
    $AWSBIN ecr describe-repositories | yq -r .repositories[].repositoryName
}

