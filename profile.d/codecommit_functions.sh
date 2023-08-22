# codecommit
coco-list() {
    aws codecommit list-repositories
}

coco-create() {
    aws codecommit create-repository --repository-name $1
}   

coco-delete() {
    aws codecommit delete-repository --repository-name $1
}   

coco-clone() {
    repo=$(coco-geturl.py $1)
    git clone $repo
}

