#! /usr/bin/env python

import boto3

client = boto3.client('cloudwatch')
paginator = client.get_paginator('list_metrics')

namespaces = set()
for page in paginator.paginate():
    for metric in page['Metrics']:
        namespaces.add(metric['Namespace'])

print(sorted(list(namespaces)))
