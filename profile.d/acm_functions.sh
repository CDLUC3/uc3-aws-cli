#!/usr/bin/env bash


acm-cert-list() {
    aws acm list-certificates | jq -r '.CertificateSummaryList[].DomainName'
}

acm-cert-show-arn() {
    DOMAIN_NAME=$1
    aws acm list-certificates | \
	jq -r ".CertificateSummaryList[] | select(.DomainName == \"$DOMAIN_NAME\") | .CertificateArn"
}

acm-cert-show() {
    DOMAIN_NAME=$1
    CERTARN=$(acm-cert-show-arn $DOMAIN_NAME)
    aws acm describe-certificate --certificate-arn $CERTARN | jq -r '.Certificate'
}

acm-cert-delete() {
    DOMAIN_NAME=$1
    CERTARN=$(acm-cert-show-arn $DOMAIN_NAME)
    aws acm delete-certificate --certificate-arn $CERTARN
}

