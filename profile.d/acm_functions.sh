#!/usr/bin/env bash


acm-cert-list() {
    $AWSBIN acm list-certificates | yq -r '.CertificateSummaryList[].DomainName'
}

acm-cert-show-arn() {
    DOMAIN_NAME=$1
    $AWSBIN  acm list-certificates | \
	yq -r ".CertificateSummaryList[] | select(.DomainName == \"$DOMAIN_NAME\") | .CertificateArn"
}

acm-cert-show() {
    DOMAIN_NAME=$1
    CERTARN=$(acm-cert-show-arn $DOMAIN_NAME)
    $AWSBIN acm describe-certificate --certificate-arn $CERTARN | yq -ry '.Certificate'
}

acm-cert-delete() {
    DOMAIN_NAME=$1
    CERTARN=$(acm-cert-show-arn $DOMAIN_NAME)
    $AWSBIN acm delete-certificate --certificate-arn $CERTARN
}

