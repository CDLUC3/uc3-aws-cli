Utility scripts for accessing AWS Client resources from UC3 servers.

## Dependencies

- ENV
  - SSM_ROOT_PATH
  - SSM_DB_NAME (for servers with mysql)
  - SSM_DB_ROLE (defaults to readonly)
- jq installed on the machine
- ssm get-parameters-by-path access


## Installation

After cloning the repository, run the setup.sh script. 

  git clone https://github.com/CDLUC3/uc3-aws-cli.git
  uc3-aws-cli/setup.sh

This script creates and installs to the following directories:

  ~/bin
  ~/.aws/cli
  ~/.profile.d

In order to source the aws shell functions,  Add the following to your ~/.bashrc:

  if [ -d ~/.profile.d ]; then
    . ~/.profile.d/*
  fi

## Installation Prerequisites

For this tools set to work properly after installation, you must install
the following RPMs:

- jq


## Installation Via Puppet

Our uc3 puppet environment now contains a module specifically to install and
provission uc3-aws-cli.

Add the following to the per-node hiera config file for each host where
uc3-aws-cli scripts are wanted.  Be sure to set the 'user' field appropriately
for each system.

  uc3_awscli::awscli::user:
    dpr2:
      user: "dpr2"



