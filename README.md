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
    ~/.profile.d

In order to source the aws shell functions,  Add the following to your ~/.bashrc:

    if [ -d ~/.profile.d ]; then
      . ~/.profile.d/*
    fi

## Installation Prerequisites

For this tools set to work properly after installation, you must install
the following RPMs:

- jq
- python3-yq (optional - SuSE only)


## Installation Via Puppet

Our uc3 puppet environment now contains a module specifically to install and
provission uc3-aws-cli.

Add the following to the per-node hiera config file for each host where
uc3-aws-cli scripts are wanted.  Be sure to set the 'user' field appropriately
for each system.

    uc3_awscli::awscli::user:
      dpr2:
        user: "dpr2"


To get puppet to update installed uc3-aws-cli scripts after a new release`, you must bump the git tag for 
of this repo and then edit the `uc3_awscli::awscli::revision` attribute:

    agould@uc3-mrtweb01x2-stg:~/puppet/uc3/modules/uc3_awscli/manifests> git diff
    diff --git a/modules/uc3_awscli/manifests/awscli.pp b/modules/uc3_awscli/manifests/awscli.pp
    index 27ed112..54e8716 100644
    --- a/modules/uc3_awscli/manifests/awscli.pp
    +++ b/modules/uc3_awscli/manifests/awscli.pp
    @@ -3,6 +3,7 @@ define uc3_awscli::awscli ($user = "",
                                $install_dir = "/$user/install",
                                $git_repo = "https://github.com/CDLUC3/uc3-aws-cli.git",
                                $setup_script = "setup.sh",
    -                           $revision = "0.0.0"
    +                           $revision = "0.0.1"

