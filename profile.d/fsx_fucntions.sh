#!/usr/bin/env bash

fsx-fs-all() {
    response=$(aws fsx describe-file-systems)
    filesystems=$(echo $response | jq -r '.FileSystems[]')
    nextmarker=$(echo $response | jq -r '.NextMarker')
    while [ ! -n $nextmarker ]; do
        response=$(aws fsx describe-file-systems)
        filesystems=$(echo $response | jq -r '.FileSystems[]')
        nextmarker=$(echo $response | jq -r '.NextMarker')
    done
    echo $filesystems
}

fsx-fs-list() {
    fsx-fs-all | jq -r '(select(.Tags != null) | .Tags[] | select(.Key == "Name") | .Value)'
}

fsx-fs-show() {
    NAME=$1
    for fs_id in $(fsx-fs-all | jq -r '.FileSystemId'); do
	response=$(aws fsx describe-file-systems --file-system-ids $fs_id)
	fs_name=$(echo $response | jq -r '.FileSystems[].Tags[] | select(.Key == "Name") | .Value')
	if [ $fs_name == $NAME ]; then
            if $(which yq 2>&1 > /dev/null); then
	        echo $response | yq -yr '.'
            else
	        echo $response | jq -r
	    fi
	fi
    done
}


