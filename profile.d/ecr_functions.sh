# ecr_functions
#

ecr-repository-list() {
    response=$(aws ecr describe-repositories)
    repositories=$(echo "$response" | jq -r '.repositories[].repositoryName')
    nexttoken=$(echo "$response" | jq -r '.nextToken')
    while [ "$nexttoken" != "null" ]; do
        response=$(aws ecr describe-repositories --starting-token $nexttoken)
        repositories="${repositories} $(echo "$response" | jq -r '.repositories[].repositoryName')"
        nexttoken=$(echo "$response" | jq -r '.nextToken')
    done
    # convert spaces into end-of-line and sort
    echo "${repositories// /$'\n'}" | sort
}

ecr-repository-show(){
    REPO_NAME=$1
    $AWSBIN ecr describe-repositories --repository-names $REPO_NAME | yq -ry '.repositories[]'
    $AWSBIN ecr get-lifecycle-policy --repository-name $REPO_NAME | yq -ry '. | del(.registryId, .repositoryName)'
}

ecr-image-list(){
    REPO_NAME=$1
    $AWSBIN ecr describe-images --repository-name $REPO_NAME | \
        yq -ry '.imageDetails[] | del(.registryId, .repositoryName, .imageManifestMediaType, .artifactMediaType, .lastRecordedPullTime)'
}
 

ecr-image-build() {
    if [ $# -ne 2 ]; then
        echo "Usage: ecr-image-build <repo name> <image tag>"
    elif [ ! -f Dockerfile ]; then
        echo "Dockerfile not found in current working directory"
    else
        ECR_REPO_NAME=$1
        IMAGE_TAG=$2
        docker buildx build --platform linux/amd64 -t $ECR_REPO_NAME:$IMAGE_TAG  --load .
    fi
}

ecr-image-push() {
    if [ $# -ne 2 ]; then
        echo "Usage: ecr-image-push <repo name> <image tag>"
    else
        ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
        ECR_ID=$ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com
        ECR_REPO_NAME=$1
        IMAGE_TAG=$2

        # to build the image from Docker file in current directory in advance:
        # docker buildx build --platform linux/amd64 -t $ECR_REPO_NAME:$IMAGE_TAG  --load .

        # Login to ECR
        aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_ID
        # Tag the image
        docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_ID/$ECR_REPO_NAME:$IMAGE_TAG
        #docker tag $ECR_REPO_NAME:latest $ECR_ID/$ECR_REPO_NAME:$IMAGE_TAG
        # Push the image up to ECR
        docker push $ECR_ID/$ECR_REPO_NAME:$IMAGE_TAG
    fi
}


ecr-image-list-ids() {
    ECR_REPO_NAME=$1
    $AWSBIN ecr list-images --repository-name $ECR_REPO_NAME | yq -r '.imageIds[].imageDigest'
}

ecr-image-delete() {
    ECR_REPO_NAME=$1
    IMAGE_ID=$2
    $AWSBIN ecr batch-delete-image --repository-name $ECR_REPO_NAME --image-ids imageDigest=$IMAGE_ID
}

ecr-repository-delete-images() {
    ECR_REPO_NAME=$1
    IMAGE_IDS=$(ecr-image-list-ids $ECR_REPO_NAME)
    for id in $IMAGE_IDS; do
	$AWSBIN ecr batch-delete-image --repository-name $ECR_REPO_NAME --image-ids imageDigest=$id
    done
}

ecr-repository-delete() {
    ECR_REPO_NAME=$1
    $AWSBIN ecr delete-repository --repository-name $ECR_REPO_NAME
}


##############################################
# Notes

# See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-retag.html
# 
# ECR_REPO_NAME=ezid-n2t-dev-web-ecr
# #OLD_TAG=v0.0.0-latest
# #NEW_TAG=dev-latest
# OLD_TAG=latest
# #NEW_TAG=previous
# NEW_TAG=dev-latest
# MANIFEST=$(aws ecr batch-get-image --repository-name $ECR_REPO_NAME --image-ids imageTag=$OLD_TAG --output text --query 'images[].imageManifest')
# #echo $MANIFEST | json2yaml
# aws ecr put-image --repository-name $ECR_REPO_NAME --image-tag $NEW_TAG --image-manifest "$MANIFEST"




