#!/usr/bin/env python

"""Obtain the http clone url from a codecommit repo

Usage:
  coco-geturl.py -h
  coco-geturl.py NAME

Options:
  -h, --help    Show this help message and exit.
  NAME          The name of the codecommit repository
"""

from __future__ import print_function
import sys
import boto3
from docopt import docopt

args = docopt(__doc__)
try:
    res = boto3.client('codecommit').get_repository(repositoryName=args['NAME'])
except Exception as e:
    print(e, file=sys.stderr)
else:
    print(res['repositoryMetadata']['cloneUrlHttp'])

