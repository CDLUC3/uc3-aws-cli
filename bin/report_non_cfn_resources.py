import boto3
#from botocore.exceptions import ClientError
import yaml
from operator import itemgetter


uc3_required_tags = [
        'CodeRepo',
        'Program',
        'Subservice',
        'Environment',
        'Service',
        'Contact'
]

services_to_ignore = [
        'ask-definition',
        'arn:aws:ssm',
        'arn:aws:servicediscovery',
]


def ignore_service(res):
    for service in services_to_ignore:
        if res['ResourceARN'].find(service) != -1:
            return True
    return False


def has_cfn_tag(res):
    keys = [ tag['Key'] for tag in res['Tags'] ]
    if 'aws:cloudformation:logical-id' in keys:
        return True
    return False


def missing_uc3_tags(res):
    keys = [ tag['Key'] for tag in res['Tags'] ]
    for tag in uc3_required_tags:
        if tag not in keys:
            return True
    return False


def nonCloudFormation():
    #for region in [ 'us-west-2', 'us-east-1', 'us-east-2' ]:
    for region in [ 'us-west-2' ]:
        nonCFres = []
        client = boto3.client('resourcegroupstaggingapi', region_name=region)
        paginator = client.get_paginator('get_resources')
        for page in paginator.paginate():
            for res in page['ResourceTagMappingList']:
                if res['ResourceARN'].startswith('arn:aws:cloudformation'):
                    pass
                elif ignore_service(res):
                    pass
                elif has_cfn_tag(res):
                    pass
                elif missing_uc3_tags(res):
                    nonCFres.append(res)
            #break

        return sorted(nonCFres, key=itemgetter('ResourceARN'))


sorted_nonCFres = nonCloudFormation()
for res in sorted_nonCFres:
    print(yaml.dump(res))

