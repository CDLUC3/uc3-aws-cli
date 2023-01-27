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
    echo $filesystems | jq -r .
}

fsx-fs-list() {
    fsx-fs-all | jq -r '(select(.Tags != null) | .Tags[] | select(.Key == "Name") | .Value)'
}

fsx-fs-show() {
    NAME=$1
    fsx-fs-all | jq -r "select(.Tags[] | select(.Key == \"Name\" and .Value == \"$NAME\"))"
}


