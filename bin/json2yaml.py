#!/usr/bin/env python
import sys
import json
import yaml

yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)
