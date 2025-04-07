Utility scripts for accessing AWS Client resources from UC3 servers.

## Dependencies

- ENV
  - SSM_ROOT_PATH
  - SSM_DB_NAME (for servers with mysql)
  - SSM_DB_ROLE (defaults to readonly)
- jq installed on the machine
- yq installed in python virtual environment
- ssm get-parameters-by-path access


## Installation

After cloning the repository, run the setup.sh script. 

    git clone https://github.com/CDLUC3/uc3-aws-cli.git
    uc3-aws-cli/setup.sh

This script creates and installs to the following directories:

    ~/bin
    ~/.profile.d

In order to source the aws shell functions,  Add the following to your ~/.bashrc:

    # Gather profile snippets - mostly my awscli functions
    if [ -d $HOME/.profile.d ]; then
      for file in $(ls -1 $HOME/.profile.d); do
        source ${HOME}/.profile.d/${file}
      done
    fi

## Installation Prerequisites

Many of the aws cli shell functions under `profile.d` require json and yaml
manipulation tools.

#### Installing `jq`

Install `jq` with yum:
```
sudo yum install jq
```

#### Installing `yq`

Install `yq` as a pip package.  This must be done within a python virtual environment.
See pyenv section below for info on setting up python virutal environments.
```
agould@uc3-aws2-ops:~> pyenv versions
* system (set by /home/agould/.pyenv/version)
  2.7.18
  3.9.16
agould@uc3-aws2-ops:~> pyenv global 2.7.18
agould@uc3-aws2-ops:~> pip install yq
```



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


## Installing Python Virtual Environment

Use `pyenv` tool to manage python virtual environments.  This must be installed into
your home directy.  See more info at: https://github.com/pyenv/pyenv

Also see [Create Python Virual Environment with pyenv](https://github.com/CDLUC3/uc3ops-ansible-inventory#create-python-virual-environment-with-pyenv) in our [UC3 Ansible Inventory](https://github.com/CDLUC3/uc3ops-ansible-inventory) repository.


The simple recipe:

```
curl https://pyenv.run | bash cat << \EOF >> ~/.bashrc

# pyenv stuff
#
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
EOF

. ~/.bashrc
pyenv install 2.7.18
pyenv versions
pyenv global 2.7.18
```
