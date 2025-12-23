#!/usr/bin/env bash
#
# S3 query functions

# List all s3 buckets
s3-bucket-list() {
    aws s3 ls | awk '{print $3}'
}

# list objects in bucket. Accepts paths.
s3-object-list() {
    BUCKET=$1
    if [ -n "$BUCKET" ]; then
        aws s3 ls s3://${BUCKET%\/}/
    else
	echo "provide a bucket name"
	exit 1
    fi
}

s3-object-list-recursive() {
    BUCKET=$1
    if [ -n "$BUCKET" ]; then
        aws s3 ls --recursive s3://${BUCKET%\/}/
    else
        echo "provide a bucket name"
        exit 1
    fi
}

# prints contents of object to screen.  must supply a full path
s3-object-cat() {
    OBJECT=$1
    if [ -n "$OBJECT" ]; then
        TEMPFILE=$(mktemp)
        aws s3 cp s3://${OBJECT%\/} $TEMPFILE
	cat $TEMPFILE
	rm $TEMPFILE
    else
        echo "provide a bucket name"
        exit 1
    fi
}

# takes 2 args: localfile bucketpath
s3-object-put() {
    localfile=$1
    bucketpath=$2
    aws s3 cp $localfile s3://${bucketpath%\/}/${localfile}
}

s3-object-delete() {
    bucketpath=$1
    aws s3 rm s3://${bucketpath}
}


# takes 2 args: bucketpath localfile 
s3-object-get() {
    bucketpath=$1
    localfile=$2
    aws s3 cp s3://${bucketpath%\/} $localfile
}



# takes 2 args: sourcepath bucketpath. soucrcpath must be a local dirctory.
s3-bucket-push() {
    sourcepath=$1
    if [ ! -d $sourcepath ];then
        echo "Local path $sourcepath not found"
    else
        bucketpath=$2
        aws s3 sync ${sourcepath%\/}/ s3://${bucketpath%\/}/
    fi
}

s3-bucket-pull() {
    localpath=$2
    if [ ! -n "$localpath" ]; then
	localpath=${bucketpath#\/}
    fi
    if [ ! -d $localpath ];then
	mkdir -p $localpath
    fi
    bucketpath=$1
    aws s3 sync s3://${bucketpath%\/}/ ${localpath%\/}/
}



