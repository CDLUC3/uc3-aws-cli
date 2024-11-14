#!/usr/bin/env python

import sys
import boto3
import yaml
import click
import difflib

# Parse the command-line parameters using 'click' decorators
@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.argument('webacl-name',
    required=True)
@click.option('--output-file', '-o',
    type=click.Path(),
    help='Filename in which to dump current webacl rules.')
@click.option('--input-file', '-i',
    type=click.Path(exists=True),
    help='Filename from which to read updated webacl rules.')
@click.option('--execute', '-x',
    is_flag=True,
    help='Set this flag to make updates real.')
def main(webacl_name, output_file, input_file, execute):
    """
Display or update webacl rules.

If no options are specified, current rules are dumped to standard out.
Use option '--output-file' to create a yaml file of current rules.  Edit 
this file with the updates you want to make.  This becomes your 'input-file'.

Rule updates are read from `--input-file`. By default your updates are
previewed only.  To make updates real, you must supply the '--execute' flag.

Examples:

  \b
  modify_waf_rules.py mhaye-test-acl
  modify_waf_rules.py mhaye-test-acl -o mhaye-test-acl.rules.yaml
  vi mhaye-test-acl.rules.yaml
  modify_waf_rules.py mhaye-test-acl -i mhaye-test-acl.rules.yaml
  modify_waf_rules.py mhaye-test-acl -i mhaye-test-acl.rules.yaml --execute
    """

    # Build the current WebACL parameters
    webacl = get_webacl_by_name(webacl_name)
    response = webacl['client'].get_web_acl(
            Name=webacl_name, Scope=webacl['scope'], Id=webacl['id'])
    params = { 'DefaultAction':    response['WebACL']['DefaultAction'],
               'VisibilityConfig': response['WebACL']['VisibilityConfig'],
               'LockToken':        response['LockToken']
             }
    if response['WebACL']['Description']:
        params['Description'] = response['WebACL']['Description']
    current_rules = response['WebACL']['Rules']

    if not input_file:
        # action is dump
        if output_file:
            with open(output_file, 'w') as f:
                f.write(yamlfmt(current_rules))
        else:
            print(yamlfmt(current_rules))
    else:
        # action is update
        with open(input_file, 'r') as f:
            try:
                new_rules = yaml.safe_load(f.read())
            except Exception as e:
                sys.exit(f"Error: can't read rules from input file {input_file!r}\n {e!r}")
        if not execute:
            # display diff of current rules and new rules
            print(string_differ(yamlfmt(current_rules), yamlfmt(new_rules)))
        else:
            params['Rules'] = new_rules
            try:
                webacl['client'].update_web_acl(
                      Name=webacl_name, Scope=webacl['scope'], Id=webacl['id'], **params)
                print("Updates to webacl '{}' successful.".format(webacl_name))
            except Exception as e:
                sys.exit(f"Update failed:\n {e!r}")

def get_webacl_by_name(webacl_name):
    '''Locate the WebACL. Look in CLOUDFRONT and REGIONAL'''
    collector = []
    aclinfo = {}
    for region, scope in [('us-east-1', 'CLOUDFRONT'), ('us-west-2', 'REGIONAL')]:
        client = boto3.client('wafv2', region_name=region)
        response = None
        next_token = None
        while response is None or next_token is not None:
            if next_token is None:
                response = client.list_web_acls(Scope=scope)
            else:
                response = client.list_web_acls(NextToken=next_token, Scope=scope)
            next_token = response.get('NextToken')
            collector += response['WebACLs']

        for webacl in collector:
            if webacl['Name'] == webacl_name:
                aclinfo = dict(
                    id=webacl['Id'],
                    client=client,
                    scope=scope,
                )
    if not aclinfo:
        sys.exit(f"Error: can't find a WAF WebACL named {webacl_name!r}")
    return aclinfo

def yamlfmt(obj):
    if isinstance(obj, str):
        return obj
    try:
        return yaml.dump(obj, default_flow_style=False)
    except Exception:  # pragma: no cover
        return yaml.dump(str(obj))

def string_differ(string1, string2):
    """Returns the diff of 2 strings"""
    diff = difflib.ndiff(
        string1.splitlines(keepends=True),
        string2.splitlines(keepends=True),
    )
    return ''.join(list(diff))

if __name__ == "__main__":
    main()
