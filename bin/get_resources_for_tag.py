#!/usr/bin/env python

import sys
import boto3
import yaml
import click
from operator import itemgetter

# Parse the command-line parameters using 'click' decorators
@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.argument('key', required=True)
@click.argument('value', required=True)
@click.option('--region', 
    default='us-west-2',
    help='AWS Region')
@click.option('--show-tags', 
    is_flag=True,
    help='Prints all tags as well as resources.')
def main(key, value, region, show_tags):
    """
Report all AWS resources with a tag matching 'key' and 'value'.
    """

    print("key: {}".format(key))
    print("value: {}".format(value))
    print("region: {}".format(region))
    print("show_tags: {}".format(show_tags))

    matching_resources = []
    client = boto3.client('resourcegroupstaggingapi', region_name=region)
    paginator = client.get_paginator('get_resources')
    for page in paginator.paginate():
        for res in page['ResourceTagMappingList']:
            if has_tag(res, key, value):
                matching_resources.append(res)
        #break

    sorted_matching_resources =sorted(matching_resources, key=itemgetter('ResourceARN'))
    for res in sorted_matching_resources:
        if show_tags:
            print(yaml.dump(res))
        else:
            print(res['ResourceARN'])


def has_tag(res, key, value):
    tag = next((item for item in res['Tags'] if item["Key"] == key and item["Value"] == value), False)
    if tag:
        return True
    return False



if __name__ == "__main__":
    main()

