# codecommit
coco-list() {
    $AWSBIN codecommit list-repositories
}

coco-create() {
    $AWSBIN codecommit create-repository --repository-name $1
}   

coco-delete() {
    $AWSBIN codecommit delete-repository --repository-name $1
}   

coco-clone() {
    repo=$(coco-geturl.py $1)
    git clone $repo
}

